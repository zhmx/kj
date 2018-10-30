

local Config = require("config");


local _M = {};

function reload(mod)
	Config = require("config");
end 

function _M.ThreadLogin(client, request_recv)
end 
function _M.ThreadLoginResponse(client, request_recv)
	if request_recv.msg ~= "" then 
		print("_M.ThreadLoginResponse login error", request_recv.msg);
		return ;
	end 
	
	if request_recv.type == Config.login.type then 
		g_LoginLoginStatus = true;
	else 
		error(request_recv.type);
	end 
end 

function _M.Ping(client, request_recv)
end 
function _M.PingResponse(client, request_recv)
	if request_recv.msg ~= "" then 
		print("_M.Ping ", request_recv.msg);
		return ;
	end 

	if request_recv.type == Config.login.type then 
		print("_M.Ping recv ping response from " .. Config.login.type .. " and get time is :" .. os.date("%Y-%m-%d %H:%M:%S", request_recv.time));
	else 
		error(request_recv.type);
	end 
end 

function _M.NotifyAccess(client, request_recv)
	local rid = request_recv.rid;
	
	local now = os.time();
	local token = g_Token[rid];
	if not token then 
		token = {
			time = now,
			rid = rid,
			key = request_recv.key,
			sdk_id = request_recv.sdk_id,
			uid = request_recv.uid,
			server_id = request_recv.server_id,
		};
		g_Token[rid] = token;
	else 
		token.time = now;
		token.key = request_recv.key;
	end 
end

return _M;