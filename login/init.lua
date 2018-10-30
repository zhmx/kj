
-- package.path = package.path .. ';./login/?.lua;'

---- 全局变量
-- 登陆验证相关
g_Client_connectors = g_Client_connectors or {};
g_ClientServer = g_ClientServer or nil;
g_RequestList = g_RequestList or {};

-- 游戏服链接相关
g_Game_connectors = g_Game_connectors or {};
g_GameServer = g_GameServer or nil;
g_GameServerIdMap = g_GameServerIdMap or {};

g_SprotoLoader = g_SprotoLoader or nil;

-- 全局数据库


local _ = require("login.clientServer");
local _ = require("login.gameServer");
g_SprotoLoader = require("login.sprotoLoader");
--
-- local Login = require("login.login");

function reload(mod)
	_ = require("login.clientServer");
	_ = require("login.gameServer");
	g_SprotoLoader = require("login.sprotoLoader");
	--
	-- Login = require("login.login");
end 

function OnSecTimer( ... )
	-- local now = os.time();
	-- -- 触发秒钟定时器
	-- xpcall(function() Login.OnSec(now); end, function (err)
	-- 	print(err); print( debug.traceback() );
	-- end)
end
