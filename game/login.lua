
local CGlobal = CGlobal;
local CServer = CServer;
local CClient = CClient;
local CHttp = CHttp;

local Token = require("data.token");
local Config = require("config");
local PlayerCache = require("game.cache.playerCache");
local GlobalConfig = require("data.global");
local MongoDB = require("mongo");

-- 1 client (token)> login server (key)> game server
-- 2 client (key)> game server 第一步必须通过 LoginGame 验证key，无论是否新用户
-- 3 client 获取用户基本信息

function reload(mod)
	Token = require("data.token");
	Config = require("config");
	PlayerCache = require("game.cache.playerCache");
	GlobalConfig = require("data.global");
	MongoDB = require("mongo");
end 

if not g_GlobalDB then 
	g_GlobalDB = MongoDB.new(Config.global.db.ip, Config.global.db.port, Config.global.db.name, Config.global.db.user, Config.global.db.pw);
end 

local _M = {};

function _M.OnDisconnect(rid)
	g_OnlineClient[rid] = nil;
end 

function _M.LoginGame(client, request_recv)
	local key = request_recv.key;
	local rid = request_recv.rid;
	local token = Token[rid];
	local now = os.time();
	if not token or now - token.time > g_KeyTimeOut then 
		return { msg = "token_error" };
	end 
	if token.key ~= key then 
		return { msg = "key_error" };
	end 
	client.key = key;	-- key验证通过 标志key
	client.rid = rid;	-- key验证通过 标志rid
	client.server_id = token.server_id;	-- key验证通过 标志server_id
	client.sdk_id = token.sdk_id;		-- key验证通过 标志sdk_id
	client.uid = token.uid;	-- key验证通过 标志uid
	local rid = token.rid;
	local cache = PlayerCache.GetByRid(rid);
	if not cache then 
		return { msg = "no_create_role" };
	end 
	-- 登陆或创建角色成功后驻留数据到内存，再请求用户信息
	PlayerCache.SetNormalInfo(client.rid, {login_time = now});
	g_OnlineClient[client.rid] = client;

	return { msg = "" };
end

function _M.CreateRole(client, request_recv)
	local sex = request_recv.sex;
	local prof = request_recv.prof;
	local name = request_recv.name;
	if not client.rid then 
		return { msg = "key_access_not_pass" };
	end 
	if name == "" or string.len(nameLen) > GlobalConfig.nameLen then 
		return { msg = "name_len_limit" };
	end 
	if string.find(name, "%p") then 
		return { msg = "name_illegal" };
	end 
	if prof ~= 1 and prof ~= 2 then 
		return { msg = "prof_error" };
	end 
	if g_NameMap[name] then 
		return { msg = "name_had_exit" };
	end 
	if PlayerCache.GetByRid(client.rid) then 
		return { msg = "have_role" };
	end 
	local now = os.time();
	local force_info = {
		sdk_id = client.sdk_id,
		server_id = client.server_id,
		uid = client.uid,
		name = name,
		sex = sex,
		prof = prof,
	};
	local normal_info = {
		login_time = now,
	};
	PlayerCache.Create(client.rid, force_info, normal_info);
	-- 新角色添加信息到全局表
	local userData = {
		_id = client.rid,
		sdk_id = client.sdk_id,
		uid = client.uid,
		server_id = client.server_id,
		time = now,
		ip = client.ip,
	};
	g_GlobalDB:Insert("user", userData);

	-- 登陆或创建角色成功后驻留数据到内存，再请求用户信息
	g_OnlineClient[client.rid] = client;

	return { msg = "" };
end 

function _M.GetInfo(client, request_recv)
	local bself = false;
	local rid = request_recv.rid;

	if rid == "" or rid == client.rid then 
		bself = true;
		rid = client.rid;
	end 

	local cache = PlayerCache.GetByRid(rid);
	if not cache then 
		return { msg = "role_not_exist" };
	end 

	local force_info = cache.force_info;
	local normal_info = cache.normal_info;
	local user_info = {
		rid = rid,
		name = force_info.name,
		sex = force_info.sex,
		exp = normal_info.exp or 0,
		prof = force_info.prof,
		vip_exp = normal_info.vip_exp or 0,
		-- 以下需要区分自己和别人
		gold = bself and normal_info.gold or 0,
		bind_gold = bself and normal_info.bind_gold or 0,
		login_time = bself and normal_info.login_time or 0,
	};

	return { user_info = user_info };
end 

return _M;