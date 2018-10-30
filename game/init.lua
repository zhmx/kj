
-- package.path = package.path .. ';./game/?.lua;' 存在 main下有login目录，game目录下有login.lua则有引用问题

---- 全局变量
-- 登陆验证相关
g_Client_connectors = g_Client_connectors or {};	-- [iAddress]
g_ClientServer = g_ClientServer or nil;
g_Token = g_Token or {};	-- [rid]
g_KeyTimeOut = 60*2;	-- key 有效期

-- 登录服
g_LoginClient = g_LoginClient or nil;
g_LoginConnectStatus = g_LoginConnectStatus or false;
g_LoginLoginStatus = g_LoginLoginStatus or false;

g_SprotoLoader = g_SprotoLoader or nil;

---- 缓存
-- 数据库
g_GameDB = g_GameDB or nil;
g_PlayerCache = g_PlayerCache or {};	-- [rid]
g_SaveTickMap = g_SaveTickMap or {};	-- [rid]
g_NameMap = g_NameMap or {};	-- [rid] 全服昵称映射 昵称变动需要更改这个内存
-- 在线
g_OnlineClient = g_OnlineClient or {};	-- [rid] 指向内容同 g_Client_connectors 一致，登陆成功后映射
-- 全局数据库
g_GlobalDB = g_GlobalDB or nil;



local LoginClient = require("game.loginClient");
local _ = require("game.clientServer");
g_SprotoLoader = require("game.sprotoLoader");
--
local PlayerCache = require("game.cache.playerCache");

function reload(mod)
	LoginClient = require("game.loginClient");
	_ = require("game.clientServer");
	g_SprotoLoader = require("game.sprotoLoader");
	--
	PlayerCache = require("game.cache.playerCache");
end 

function OnSecTimer( ... )
	local now = os.time();
	-- 触发秒钟定时器
	xpcall(function() PlayerCache.OnSec(now); end, function (err)
		print(err); print( debug.traceback() );
	end)
	xpcall(function() LoginClient.OnSec(now); end, function (err)
		print(err); print( debug.traceback() );
	end)
end
