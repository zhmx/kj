
local CGlobal = CGlobal;
local CServer = CServer;
local CClient = CClient;
local CHttp = CHttp;

local g_Token = require("data.token");
local Json = require("json");
local Config = require("config");

function reload(mod)
	g_Token = require("data.token");
	Json = require("json");
	Config = require("config");
end 



local _M = {};

local function GetRid(uid, sdkId, serverId)
	return CGlobal:md5(uid .. "_" .. sdkId .. "_" .. serverId);
end
local function GetKey(rid)
	return CGlobal:md5(rid..os.time()..os.clock());
end
-- 校验token并且返回uid
local function Check(client, sdkId, token, serverId)
	local tokenConfig = g_Token[sdkId];
	if not tokenConfig then 
		error("sdkId not define: " .. sdkId);
	end 

	local page = "";
	local data = "";
	if sdkId == 2 then -- 360
		-- https://open.mgame.360.cn/user/me.json?access_token=12345678983b38aabcdef387453ac8133ac3263987654321&fields=id,name,avatar,sex,area
		page = tokenConfig.page .. "?access_token=" .. token;
	else 
		error("sdkId not define : " .. sdkId);
	end 

	local http = CHttp.new();
	assert(http:RegCallBack(CGlobal.STATIC_ON_DATA, "Http_ON_DATA"));
	assert(http:RegCallBack(CGlobal.STATIC_ON_DISCONNECT, "Http_ON_DISCONNECT"));
	local iAddress = http:GetAddress();

	g_RequestList[iAddress] = g_RequestList[iAddress] or {
		http = http,
		sdkId = sdkId,
		token = token,
		serverId = serverId,
		client = client,
	};

	http:GetPost(tokenConfig.operator, tokenConfig.host, page, data);
end
local function NotifyGameAccess(connector, request)
	local proto = "NotifyAccess"
	local msgId = SprotoLoader.protoMap[proto].session;
	local data = SprotoLoader.protops:request_encode(proto, request);
	connector:Send(msgId, data, #data);
end
function Http_ON_DATA(iAddress, header, body)
	print("Http_ON_DATA", iAddress);

	local request = g_RequestList[iAddress];
	g_RequestList[iAddress] = nil;
	request.http:Stop();
	local connector = request.client.connector;

	if not g_Client_connectors[connector:GetAddress()] then -- 掉线
		print("client lost or not found", connector:GetAddress());
		return ;
	end 

	local uid = nil;
	local msg, key, ip, port, rid;

	if not g_GameServerIdMap[request.serverId] then 
		msg = "game_not_found";
	elseif request.sdkId == 1 then 

	elseif request.sdkId == 2 then 
		local respon = Json:decode(body);
		if respon.error_code then -- 有错
			msg = respon.error;
		else 
			uid = respon.id;
		end 
	else 
		msg = "sdk_not_define";
	end 
	if msg == "" then 
		-- response 给玩家
		rid = GetRid(uid, request.sdkId, request.serverId);
		key = GetKey(rid);
		ip = g_GameServerIdMap[request.serverId].ip;
		port = g_GameServerIdMap[request.serverId].port;
		-- login 验证成功后 notify 给 game
		local notifyAccessData = {
			key = key,
			rid = rid,
			sdk_id = request.sdkId,
			uid = uid,
			server_id = request.serverId,
		};
		NotifyGameAccess(g_GameServerIdMap[request.serverId].connector, notifyAccessData);
	end 

	local response = {
		msg = msg,
		key = key,
		ip = ip,
		port = port,
	};
	local proto = "Login"
	local msgId = SprotoLoader.protoMap[proto].session;
	local data = SprotoLoader.protops:response_encode(proto, response);
	connector:Send(msgId, data, #data);
end
function Http_ON_DISCONNECT(iAddress, msg)
	print("Http_ON_DISCONNECT", iAddress, msg);
	g_RequestList[iAddress] = nil;
end

function _M.OnDisconnect(iAddress)
	for _iAddress, tab in pairs(g_RequestList) do 
		local __iAddress = tab.client.iAddress;
		if __iAddress == iAddress then 
			local http = tab.http;
			g_RequestList[_iAddress] = nil;
			http:Stop();
			break;
		end 
	end 
end

function _M.Login(client, request_recv)
	if not g_GameServerIdMap[request_recv.serverId] then 
		return { msg = "game_not_found" }
	end 
	if request_recv.sdkId == 1 then 
		local rid = GetRid(request_recv.uid, request_recv.sdkId, request_recv.serverId);
	else
		Check(client, request_recv.sdkId, request_recv.token, request_recv.serverId);
	end 
end

return _M;