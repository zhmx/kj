
local CMongo = CMongo;
require("class");
local Json = require("json");

local Mongo = class();

function Mongo:ctor(ip, port, dbname, user, pw)
	self.mongo = CMongo.new(ip, port, user, pw);
	self.ip = ip;
	self.port = port;
	self.dbname = dbname;
	self.user = user;
	self.pw = pw;
	self.log_module = log_module;
	self.collections = {};
end 

function Mongo:Update(tablename, condition, data, upser)
	if not self.collections[tablename] then 
		self.collections[tablename] = self.mongo:GetCollection(self.dbname, tablename);
	end 
	if not self.collections[tablename] then 
		error("Mongo:Update cannot get collection :" .. self.dbname .. " " .. tablename);
	end 
	local collection = self.collections[tablename];
	local status = collection:Update(Json:encode(condition), Json:encode(data), upser);
	if status ~= true then 
		error("Mongo:Update update failed :" .. self.dbname .. " " .. tablename);
	end 
	return status;
end

function Mongo:Insert(tablename, data)
	if not self.collections[tablename] then 
		self.collections[tablename] = self.mongo:GetCollection(self.dbname, tablename);
	end 
	if not self.collections[tablename] then 
		error("Mongo:Insert cannot get collection :" .. self.dbname .. " " .. tablename);
	end 
	local collection = self.collections[tablename];
	local status = collection:Insert(Json:encode(data));
	if status ~= true then 
		error("Mongo:Insert insert failed :" .. self.dbname .. " " .. tablename);
	end 
	return status;
end

function Mongo:Delete(tablename, condition)
	if not self.collections[tablename] then 
		self.collections[tablename] = self.mongo:GetCollection(self.dbname, tablename);
	end 
	if not self.collections[tablename] then 
		error("Mongo:Delete cannot get collection :" .. self.dbname .. " " .. tablename);
	end 
	local collection = self.collections[tablename];
	local status = collection:Delete(Json:encode(condition));
	if status ~= true then 
		error("Mongo:Delete delete failed :" .. self.dbname .. " " .. tablename);
	end 
	return status;
end

function Mongo:Fetch(tablename, condition)
	if not self.collections[tablename] then 
		self.collections[tablename] = self.mongo:GetCollection(self.dbname, tablename);
	end 
	if not self.collections[tablename] then 
		error("Mongo:Fetch cannot get collection :" .. self.dbname .. " " .. tablename);
	end 
	local collection = self.collections[tablename];
	local result = collection:Fetch(Json:encode(condition));
	return Json:decode(result);
end

function Mongo:DropTab(tablename)
	if not self.collections[tablename] then 
		self.collections[tablename] = self.mongo:GetCollection(self.dbname, tablename);
	end 
	if not self.collections[tablename] then 
		error("Mongo:DropTab cannot get collection :" .. self.dbname .. " " .. tablename);
	end 
	local collection = self.collections[tablename];
	local result = collection:Drop();
	if result ~= true then 
		error("Mongo:DropTab failed :" .. self.dbname .. " " .. tablename);
	end 
	return result;
end

function Mongo:EnsureIndex(tablename, keys)
	if not self.collections[tablename] then 
		self.collections[tablename] = self.mongo:GetCollection(self.dbname, tablename);
	end 
	if not self.collections[tablename] then 
		error("Mongo:v cannot get collection :" .. self.dbname .. " " .. tablename);
	end 
	local collection = self.collections[tablename];
	local result = collection:EnsureIndex(Json:encode(keys));
	if result ~= true then 
		error("Mongo:EnsureIndex failed :" .. self.dbname .. " " .. tablename);
	end 
	return result;
end

return Mongo;