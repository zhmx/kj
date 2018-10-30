-- name                             string                           参数名
-- param                            int                              参数
-- cn                               string                           注释

return {
	["checkTime"] = {
		param = 20,
		cn = "数据库保存检查时长",
	},
	["saveTime"] = {
		param = 120,
		cn = "多久保存一次数据",
	},
	["nameLen"] = {
		param = 15,
		cn = "角色名字长度",
	},
}
