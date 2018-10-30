

local sproto = require("sproto");

function reload(mod)
	sproto = require("sproto");
end 

-- tmptick = tmptick or 1; 重复引用跟踪
-- if tmptick == 2 then 
-- 	local a = a.a;
-- end 
-- tmptick = tmptick + 1;

--[[
Login 1 {

}
1 就是 session
--]]
local function GetSession(sprotoStr, proto)
	local str = string.match(sprotoStr, proto .. "%s*%d+");
	if not str then return ; end 
	str = string.gsub(str, proto, "");
	return tonumber(str);
end

local baseStr = require("data.sproto.base");
print("load sproto file: data.sproto.base");
local includes = {
	"1_login",
	"50_thread",
};

local sprotoStr = "";
for _, proto_mod in ipairs(includes) do 
	print("load sproto file: data.sproto." .. proto_mod);
	local sprotoData = require("data.sproto." .. proto_mod);
	-- print(sprotoData);
	sprotoStr = sprotoStr .. sprotoData;
	-- os.execute("pause");
end 
sprotoStr = baseStr .. sprotoStr;
-- print(sprotoStr);
local protops = sproto.parse(sprotoStr);


-- proto 关联脚本 进程协议不使用 response，而使用 异步通知
local protoMap = {
	NotifyAccess = {proto = "NotifyAccess", logic = require("login.thread"), session = GetSession(sprotoStr, "NotifyAccess")},
	ThreadLogin = {proto = "ThreadLogin", logic = require("login.thread"), session = GetSession(sprotoStr, "ThreadLogin")},
	ThreadLoginResponse = {proto = "ThreadLoginResponse", logic = require("login.thread"), session = GetSession(sprotoStr, "ThreadLoginResponse")},
	Ping = {proto = "Ping", logic = require("login.thread"), session = GetSession(sprotoStr, "Ping")},
	PingResponse = {proto = "PingResponse", logic = require("login.thread"), session = GetSession(sprotoStr, "PingResponse")},

	--
	Login = {proto = "Login", logic = require("login.login"), session = GetSession(sprotoStr, "Login")},

};
-- session 关联 proto 可以通过 session 查找对应的 proto，然后再找相关的逻辑脚本
local sessionMap = {};
for proto, v in pairs(protoMap) do 
	sessionMap[v.session] = proto;
end 
-- 检测协议
local tmp = {};
for proto, v in pairs(protoMap) do 
	assert(protops:exist_proto(proto));	-- 协议定义要存在
	assert(v.logic[proto]);				-- 协议定义对应的逻辑方法要存在
	if not v.session then 
		error(proto .. " session not define");
	end 
end 

return {
	-- local data, session = protops:request_encode("foobar", { what = "hello"})
	-- protops:request_decode("foobar", data)
	-- local data = protops:response_encode("foobar", { ok = true })
	-- protops:response_decode("foobar", data)
	protops = protops, 
	protoMap = protoMap,	-- proto 映射 脚本
	sessionMap = sessionMap,-- session 映射 proto
};