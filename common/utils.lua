-- 不可热更
local print = print;
_G._print = print;
function print_new( ... )
	local t = os.date("%Y-%m-%d %H:%M:%S", os.time());
	print(t, ... );
end
_G.print = print_new;


---------

local require = require;
_G._require = require;
function require_new( ... )
	local param = {...};
	-- print("require module:", param[1]);
	return require( ... );
end
_G.require = require_new;