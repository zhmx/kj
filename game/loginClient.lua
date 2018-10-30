
local CGlobal = CGlobal;
local CServer = CServer;
local CClient = CClient;

local Config = require("config");

local _M = {};

function reload(mod)
	Config = require("config");
end 

if not g_LoginClient then 
	g_LoginClient = CClient.new();
	g_LoginClient:Connect(Config.login.game.ip, Config.login.game.port);
end 

g_LoginConnectStatus = g_LoginConnectStatus or false;
g_LoginLoginStatus = g_LoginLoginStatus or false;

function Login_Client_ON_ACCEPT()
	print("Login_Client_ON_ACCEPT");
	g_LoginConnectStatus = true;
end 
function Login_Client_ON_DATA(msgId, data)
	print("Login_Client_ON_DATA", msgId);
	
	local proto = g_SprotoLoader.sessionMap[msgId];
	if not proto then 
		print("msgId " .. msgId .. " not define !!!");
		return ;
	end 

	local request_recv = g_SprotoLoader.protops:request_decode(proto, data); -- 接收请求
	if not request_recv then 
		print("data decode error !!!");
		return ;
	end 
	local logic = g_SprotoLoader.protoMap[proto].logic;
	if not logic[proto] then 
		print("function " .. proto .. " not define !!!");
		return ;
	end 
	local ret = logic[proto](g_LoginClient, request_recv);
	if ret then 
		local data = g_SprotoLoader.protops:response_encode(proto, ret);
		g_LoginClient:Send(msgId, data, #data);
	end 
end 
function Login_Client_ON_DISCONNECT()
	print("Login_Client_ON_DISCONNECT");
	g_LoginConnectStatus = false;
	g_LoginLoginStatus = false;
end 

g_LoginClient:RegCallBack(CGlobal.STATIC_ON_ACCEPT, "Login_Client_ON_ACCEPT");
g_LoginClient:RegCallBack(CGlobal.STATIC_ON_DATA, "Login_Client_ON_DATA");
g_LoginClient:RegCallBack(CGlobal.STATIC_ON_DISCONNECT, "Login_Client_ON_DISCONNECT");

local pingTick = 0;
function _M.OnSec(now)
	pingTick = pingTick + 1;
	if pingTick % 60 == 0 then -- 一分钟重置一次
		pingTick = 0;
	end 

	if not g_LoginConnectStatus then 
		if pingTick % 3 == 0 then -- 每3秒尝试链接
			g_LoginClient:Connect(Config.login.game.ip, Config.login.game.port);
		end 
	else
		if g_LoginLoginStatus then 
			if pingTick % 60 == 0 then -- 分钟心跳包
				local data = {
					type = Config.game.type,
				};
				local proto = "Ping";
				data = g_SprotoLoader.protops:request_encode(proto, data);
				g_LoginClient:Send(g_SprotoLoader.protoMap[proto].session, data, #data);
			end 
		else 
			if pingTick % 2 == 0 then -- 链接每2秒尝试登陆
				local data = {
					serverId = Config.game.serverId,
					ip = Config.game.client.ip,
					port = Config.game.client.port,
					type = Config.game.type,
					merge_serverIds = Config.game.merge_serverIds,
				};
				local proto = "ThreadLogin";
				data = g_SprotoLoader.protops:request_encode(proto, data);
				g_LoginClient:Send(g_SprotoLoader.protoMap[proto].session, data, #data);
			end
		end 
	end 

end

return _M;