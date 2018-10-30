

local Config = require("config");


local _M = {};

function reload(mod)
	Config = require("config");
end 

function _M.ThreadLoginResponse(client, request_recv)
end 
function _M.ThreadLogin(client, request_recv)
	local serverId = request_recv.serverId;
	if request_recv.type == Config.game.type then 
		if g_GameServerIdMap[serverId] then 
			print("_M.ThreadLogin serverId already exist", serverId);
			return ;
		end 
		print("_M.ThreadLogin recv game login", serverId, request_recv.ip, request_recv.port);
		g_GameServerIdMap[serverId] = client;
	else 
		error(request_recv.type);
	end 
	client.ip = request_recv.ip;
	client.port = request_recv.port;
	client.serverId = serverId;
	client.type = request_recv.type;

	local data = {
		msg = "",
		type = Config.login.type,
	};
	local proto = "ThreadLoginResponse";
	data = g_SprotoLoader.protops:request_encode(proto, data);
	client.connector:Send(g_SprotoLoader.protoMap[proto].session, data, #data);
end 

function _M.NotifyAccess(client, request_recv, response_recv)
end 

function _M.Ping(client, request_recv)
	local data = {
		msg = "",
		type = Config.login.type,
		time = os.time(),
	};
	local proto = "PingResponse";
	data = g_SprotoLoader.protops:request_encode(proto, data);
	client.connector:Send(g_SprotoLoader.protoMap[proto].session, data, #data);
end 
function _M.PingResponse(client, request_recv)
end 

function _M.OnDisconnect(iAddress)
	for serverId, client in pairs(g_GameServerIdMap) do 
		if client.iAddress == iAddress then 
			g_GameServerIdMap[serverId] = nil;
			break;
		end 
	end 
end

return _M;