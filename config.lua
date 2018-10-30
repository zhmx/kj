return {
	global = {
		db = {
			ip = "127.0.0.1",
			port = 27017,
			name = "global",
			user = "",
			pw = "",
		},
	},
	login = {
		client = {
			ip = "127.0.0.1",
			port = 5000,
		},
		game = {
			ip = "127.0.0.1",
			port = 5001,
		},
		type = "login",
	},
	battle = {
		ip = "127.0.0.1",
		port = 5010,
		type = "battle",
	},
	game = {
		serverId = 1,
		type = "game",
		client = {
			ip = "127.0.0.1",
			port = 5020,
		},
		merge_serverIds = { -- 哪些服合过来

		},
		dbgame = {
			ip = "127.0.0.1",
			port = 27017,
			name = "game_" .. 1, -- serverId 服务器id
			user = "",
			pw = "",
		},
	},
}