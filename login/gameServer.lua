
local CGlobal = CGlobal;
local CServer = CServer;
local CClient = CClient;

local Config = require("config");
local Thread = require("login.thread");

function reload(mod)
	Config = require("config");
	Thread = require("login.thread");
end 

if not g_GameServer then 
	print("create g_GameServer server");
	g_GameServer = CServer.new();
	g_GameServer:StartListen(Config.login.game.port);
end 

function GameServer_ON_ACCEPT(connector)
	local ip = connector:GetIP();
	local iAddress = connector:GetAddress();
	print("GameServer_ON_ACCEPT", ip, iAddress);
	g_Game_connectors[iAddress] = {connector = connector, ip = ip, iAddress = iAddress};
end 
function GameServer_ON_DATA(iAddress, msgId, data)
	print("GameServer_ON_DATA", msgId);

	local proto = g_SprotoLoader.sessionMap[msgId];
	if not proto then 
		print("msgId " .. msgId .. " not define !!!");
		return ;
	end 
	local request_recv = g_SprotoLoader.protops:request_decode(proto, data); -- 接收请求
	if not request_recv then 
		print("data decode error !!!", proto);
		return ;
	end 
	local logic = g_SprotoLoader.protoMap[proto].logic;
	if not logic[proto] then 
		print("function " .. proto .. " not define !!!");
		return ;
	end 
	if not g_Game_connectors[iAddress].serverId and proto ~= "ThreadLogin" then 
		print("game thread not login " .. g_Game_connectors[iAddress].ip);
		return ;
	end 
	local ret = logic[proto](g_Game_connectors[iAddress], request_recv);
	if ret then 
		local data = g_SprotoLoader.protops:response_encode(proto, ret);
		g_Game_connectors[iAddress].connector:Send(msgId, data, #data);
	end 
end 
function GameServer_ON_DISCONNECT(iAddress)
	print("GameServer_ON_DISCONNECT", iAddress);
	local client = g_Game_connectors[iAddress];
	g_Game_connectors[iAddress] = nil;
	-- 触发掉线
	xpcall(function() Thread.OnDisconnect(iAddress); end, function (err)
		print(err); print( debug.traceback() );
	end)
	
end 

g_GameServer:RegCallBack(CGlobal.STATIC_ON_ACCEPT, "GameServer_ON_ACCEPT");
g_GameServer:RegCallBack(CGlobal.STATIC_ON_DATA, "GameServer_ON_DATA");
g_GameServer:RegCallBack(CGlobal.STATIC_ON_DISCONNECT, "GameServer_ON_DISCONNECT");
