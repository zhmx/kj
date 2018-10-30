
-- 进程协议不使用 response 而使用协议异步 request 返回
return [[
# 进程间登录
ThreadLogin 50 {
	request {
		serverId 0 : integer
		ip 1 : string		# 外网
		port 2 : integer	# 外网
		type 3 : string		# 请求服类型
		merge_serverIds 4 : *integer # 合服到 serverId 的服的id
	}

}
ThreadLoginResponse 51 {
	request {
		msg 0 : string		# 为空则成功 非空为错误码
		type 1 : string		# 响应服类型
	}
}

Ping 52 {
	request {
		type 0 : string		# 请求服类型
	}
}
PingResponse 53 {
	request {
		msg 0 : string		# 为空则成功 非空为错误码
		time 1 : integer
		type 2 : string		# 响应服类型
	}
}

# login 服通知 game 关于 client 验证成功后的key等信息
NotifyAccess 54 {
	request {
		key 0 : string		# login 的key
		rid 1 : string		# 角色id
		sdk_id 2 : integer	# 渠道id
		uid 3 : string		# 渠道用户id
		server_id 4 : integer		# 注册服
	}
}
]]