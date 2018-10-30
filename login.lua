-- 不可热更
local LINUX = os.getenv("WinDir") == nil;
if LINUX then 
	package.cpath = package.cpath .. ';./lib/?.so;'
else 
	package.cpath = package.cpath .. ';./lib/?.dll;'
end 

package.path = package.path .. ';./common/?.lua;'

require("utils");

xpcall(
	function ( ... )
		assert( require("login.init") );
	end,
	function (err)
		print(err);
		print( debug.traceback() );
	end
)



