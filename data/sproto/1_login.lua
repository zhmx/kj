return [[
# 玩家登录 login 服
Login 1 {
	request {
		sdkId 0 : integer
		token 1 : string
		serverId 2 : integer
		uid 3 : integer		# debug 用
	}

	response {
		msg 0 : string		# 为空则成功 非空为错误码
		key 1 : string		# 登陆 game 的 key
		ip 2 : string
		port 3 : integer
	}
}
# 玩家登录 game 服
LoginGame 2 {
	request {
		key 0 : string		# 与 login 发送过来的 key 验证
		rid 1 : string
	}

	response {
		msg 0 : string		# 为空则成功 非空为错误码
	}
}
# 创建角色
CreateRole 3 {
	request {
		sex 0 : boolean		# 性别
		prof 1 : integer	# 职业
		name 2 : string		# 名称
	}

	response {
		msg 0 : string		# 为空则成功 非空为错误码
	}
}
# 获取角色信息
GetInfo 4 {
	request {
		rid 0 : string	# 不传默认获取自己信息
	}

	response {
		msg 0 : string		# 为空则成功 非空为错误码
		user_info 1 : UserInfo
	}
}
]]