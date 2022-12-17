local json = require("serializer.json")
local web = require("web")
function grabUserStats(userCode)
	-- userCode: 'xxx#123'
	local body = json.encode({
		operationName = "AccountManagementPageQuery", 
		variables = {
			cc = string.format("%s", userCode),
			uid = string.format("%s", userCode)
		}, 
		query = "fragment userProfilePage on User {\n  fbUid\n  displayName\n  connectCode {\n    code\n    __typename\n  }\n  status\n  activeSubscription {\n    level\n    hasGiftSub\n    __typename\n  }\n  rankedNetplayProfile {\n    id\n    ratingOrdinal\n    ratingUpdateCount\n    wins\n    losses\n    dailyGlobalPlacement\n    dailyRegionalPlacement\n    continent\n    characters {\n      id\n      character\n      gameCount\n      __typename\n    }\n    __typename\n  }\n  __typename\n}\n\nquery AccountManagementPageQuery($cc: String!, $uid: String!) {\n  getUser(fbUid: $uid) {\n    ...userProfilePage\n    __typename\n  }\n  getConnectCode(code: $cc) {\n    user {\n      ...userProfilePage\n      __typename\n    }\n    __typename\n  }\n}\n"
	})
	print(body)

	local res = web.post(
		'https://gql-gateway-dot-slippi.uc.r.appspot.com/graphql',
		body,
		{
			["Content-Type"] = "application/json",
			["Content-Length"] = string.len(body)
		},
		function(event)
			data = json.decode(event.response)
			if data.data and data.data.getConnectCode.user.displayName then
				return {data.data.getConnectCode.user.displayName, math.floor(data.data.getConnectCode.user.rankedNetplayProfile.ratingOrdinal)}
			end
			return {'', ''}
		end)
	-- if not response_body.data or not response_body.data.getConnectCode then return {'', ''} end
	-- return {response_body.data.getConnectCode.user.displayName, math.floor(response_body.data.getConnectCode.user.rankedNetplayProfile.ratingOrdinal)}
end