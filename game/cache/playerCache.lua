
local CGlobal = CGlobal;
local CServer = CServer;
local CClient = CClient;
local CHttp = CHttp;


local Config = require("config");
local MongoDB = require("mongo");
local GlobalConfig = require("data.global");

if not g_GameDB then 
	g_GameDB = MongoDB.new(Config.game.dbgame.ip, Config.game.dbgame.port, Config.game.dbgame.name, Config.game.dbgame.user, Config.game.dbgame.pw);
end 

if not next(g_NameMap) then 
	local force_infos = g_GameDB:Fetch("force_info", {});
	for index, force_info in ipairs(force_infos or {}) do 
		g_NameMap[force_info.name] = true;
	end 
end 

function reload(mod)
	Config = require("config");
	MongoDB = require("mongo");
	GlobalConfig = require("data.global");
end 

--[[
force_info
{
	sdk_id
	server_id
	uid
	name
	sex
	prof
}
normal_info
{
	gold
	bind_gold
	exp
	online_time
	login_time
	vip_exp
}
--]]
local _M = {};

local tick = 0;
function _M.OnSec(now)
	tick = tick + 1;
	if tick >= GlobalConfig.checkTime.param then -- n秒检查一次
		for rid, cache in pairs(g_PlayerCache) do 
			g_SaveTickMap[rid] = g_SaveTickMap[rid] and g_SaveTickMap[rid] + tick or tick;
			if g_SaveTickMap[rid] >= GlobalConfig.saveTime then -- n秒保存一次数据
				_M.SavePlayer(rid);
				g_SaveTickMap[rid] = 0;
			end 
		end 
		tick = 0;
	end 
end 

function _M.SavePlayer(rid)
	assert(rid ~= nil);
	local cache = g_PlayerCache[rid];
	if not g_PlayerCache[rid] then return ; end 
	for table_name, data in pairs(cache) do 
		if data.change_sign then -- 数据更改标志
			data.change_sign = nil;
			g_GameDB:Update(table_name, {_id = data._id}, data, true);
		end 
	end 
	if not g_OnlineClient[rid] then -- 清除离线玩家缓存
		g_PlayerCache[rid] = nil;
	end 
end

function _M.Create(rid, force_info, normal_info)
	assert(g_PlayerCache[rid] == nil);

	assert(force_info.sdk_id ~= nil);
	assert(force_info.server_id ~= nil);
	assert(force_info.uid ~= nil);
	assert(force_info.name ~= nil);
	assert(force_info.sex ~= nil);
	assert(force_info.prof ~= nil);

	assert(normal_info.login_time ~= nil);

	g_PlayerCache[rid] = {};
	local cache = g_PlayerCache[rid];
	cache.force_info = force_info;
	cache.force_info.change_sign = true;
	g_NameMap[force_info.name] = true;	-- 全服昵称映射

	cache.normal_info = normal_info;
	cache.normal_info.change_sign = true;

	return cache;
end 

function _M.SetForceInfo(rid, force_info)
	assert(g_PlayerCache[rid] ~= nil);
	local cache = g_PlayerCache[rid];
	local _force_info = cache.force_info;
	for k, v in pairs(force_info) do 
		_force_info[k] = v;
	end 
	if next(force_info) then 
		_force_info.change_sign = true;
	end 
end 

function _M.SetNormalInfo(rid, normal_info)
	assert(g_PlayerCache[rid] ~= nil);
	local cache = g_PlayerCache[rid];
	local _normal_info = cache.normal_info;
	for k, v in pairs(normal_info) do 
		_normal_info[k] = v;
	end 
	if next(normal_info) then 
		_normal_info.change_sign = true;
	end 
end 

function _M.GetByRid(rid)
	assert(rid ~= nil);
	local cache = {};
	if not g_PlayerCache[rid] then 
		-- from db
		local force_info = g_GameDB:Fetch("force_info", {_id = rid});
		if not force_info then 
			return nil;
		end 
		cache.force_info = force_info;	-- 要用表名做key
		local normal_info = g_GameDB:Fetch("normal_info", {_id = rid});
		cache.normal_info = normal_info;
	else 
		-- 系统热更后有新表增加 或者已有缓存，有新表增加
		cache.force_info = g_PlayerCache[rid].force_info or g_GameDB:Fetch("force_info", {_id = rid});
		cache.normal_info = g_PlayerCache[rid].normal_info or g_GameDB:Fetch("normal_info", {_id = rid});
	end 
	return cache;
end


return _M;