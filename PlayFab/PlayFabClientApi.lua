






local IPlayFabHttps = require("PlayFab.IPlayFabHttps")
local PlayFabSettings = require("PlayFab.PlayFabSettings")

local PlayFabClientApi = {
	settings = PlayFabSettings.settings,


	IsClientLoggedIn = function ()
		return PlayFabSettings._internalSettings.sessionTicket ~= nil
	end }

function PlayFabClientApi._MultiStepClientLogin(needsAttribution)
	if needsAttribution and not PlayFabSettings.settings.disableAdvertising and PlayFabSettings.settings.advertisingIdType and PlayFabSettings.settings.advertisingIdValue then
		local request = { }
		if PlayFabSettings.settings.advertisingIdType == PlayFabSettings.settings.AD_TYPE_IDFA then
			request.Idfa = PlayFabSettings.settings.advertisingIdValue
		elseif PlayFabSettings.settings.advertisingIdType == PlayFabSettings.settings.AD_TYPE_ANDROID_ID then
			request.Adid = PlayFabSettings.settings.advertisingIdValue
		else
			return
		end
		PlayFabClientApi.AttributeInstall(request, nil, nil)
	end
end





function PlayFabClientApi.GetPhotonAuthenticationToken(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPhotonAuthenticationToken", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetTitlePublicKey(request, onSuccess, onError)
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetTitlePublicKey", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.GetWindowsHelloChallenge(request, onSuccess, onError)
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetWindowsHelloChallenge", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithAndroidDeviceID(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithAndroidDeviceID", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithCustomID(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithCustomID", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithEmailAddress(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithEmailAddress", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithFacebook(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithFacebook", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithGameCenter(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithGameCenter", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithGoogleAccount(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithGoogleAccount", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithIOSDeviceID(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithIOSDeviceID", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithKongregate(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithKongregate", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithPlayFab(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithPlayFab", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithSteam(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithSteam", request, nil, nil, onSuccess, onError)
end

function PlayFabClientApi.LoginWithXbox(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithXbox", request, nil, nil, onSuccess, onError)
end

function PlayFabClientApi.LoginWithPSN(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithPSN", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithTwitch(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithTwitch", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.LoginWithWindowsHello(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/LoginWithWindowsHello", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.RegisterPlayFabUser(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/RegisterPlayFabUser", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.RegisterWithWindowsHello(request, onSuccess, onError)
	request.TitleId = PlayFabSettings.settings.titleId
	local externalOnSuccess = onSuccess
	local function wrappedOnSuccess(result)
		PlayFabSettings._internalSettings.sessionTicket = result.SessionTicket
		if externalOnSuccess then
			externalOnSuccess(result)
		end
		PlayFabClientApi._MultiStepClientLogin(result.SettingsForUser.NeedsAttribution)
	end
	onSuccess = wrappedOnSuccess
	IPlayFabHttps.MakePlayFabApiCall("/Client/RegisterWithWindowsHello", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.SetPlayerSecret(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/SetPlayerSecret", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AddGenericID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/AddGenericID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AddUsernamePassword(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/AddUsernamePassword", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetAccountInfo(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetAccountInfo", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayerCombinedInfo(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayerCombinedInfo", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayerProfile(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayerProfile", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayFabIDsFromFacebookIDs(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayFabIDsFromFacebookIDs", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayFabIDsFromGameCenterIDs(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayFabIDsFromGameCenterIDs", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayFabIDsFromGenericIDs(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayFabIDsFromGenericIDs", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayFabIDsFromGoogleIDs(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayFabIDsFromGoogleIDs", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayFabIDsFromKongregateIDs(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayFabIDsFromKongregateIDs", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayFabIDsFromSteamIDs(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayFabIDsFromSteamIDs", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayFabIDsFromTwitchIDs(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayFabIDsFromTwitchIDs", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkAndroidDeviceID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkAndroidDeviceID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkCustomID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkCustomID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkFacebookAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkFacebookAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkGameCenterAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkGameCenterAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkGoogleAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkGoogleAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkIOSDeviceID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkIOSDeviceID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkKongregate(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkKongregate", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkSteamAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkSteamAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkTwitch(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkTwitch", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.LinkWindowsHello(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/LinkWindowsHello", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.RemoveGenericID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/RemoveGenericID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ReportPlayer(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ReportPlayer", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.SendAccountRecoveryEmail(request, onSuccess, onError)
	IPlayFabHttps.MakePlayFabApiCall("/Client/SendAccountRecoveryEmail", request, nil, nil, onSuccess, onError)
end





function PlayFabClientApi.UnlinkAndroidDeviceID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkAndroidDeviceID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkCustomID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkCustomID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkFacebookAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkFacebookAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkGameCenterAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkGameCenterAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkGoogleAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkGoogleAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkIOSDeviceID(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkIOSDeviceID", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkKongregate(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkKongregate", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkSteamAccount(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkSteamAccount", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkTwitch(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkTwitch", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlinkWindowsHello(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlinkWindowsHello", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdateAvatarUrl(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdateAvatarUrl", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdateUserTitleDisplayName(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdateUserTitleDisplayName", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetFriendLeaderboard(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetFriendLeaderboard", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetFriendLeaderboardAroundPlayer(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetFriendLeaderboardAroundPlayer", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetLeaderboard(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetLeaderboard", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetLeaderboardAroundPlayer(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetLeaderboardAroundPlayer", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayerStatistics(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayerStatistics", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayerStatisticVersions(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayerStatisticVersions", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetUserData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetUserData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetUserPublisherData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetUserPublisherData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetUserPublisherReadOnlyData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetUserPublisherReadOnlyData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetUserReadOnlyData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetUserReadOnlyData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdatePlayerStatistics(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdatePlayerStatistics", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdateUserData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdateUserData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdateUserPublisherData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdateUserPublisherData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetCatalogItems(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetCatalogItems", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPublisherData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPublisherData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetStoreItems(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetStoreItems", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetTime(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetTime", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetTitleData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetTitleData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetTitleNews(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetTitleNews", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AddUserVirtualCurrency(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/AddUserVirtualCurrency", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ConfirmPurchase(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ConfirmPurchase", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ConsumeItem(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ConsumeItem", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetCharacterInventory(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetCharacterInventory", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPurchase(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPurchase", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetUserInventory(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetUserInventory", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.PayForPurchase(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/PayForPurchase", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.PurchaseItem(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/PurchaseItem", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.RedeemCoupon(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/RedeemCoupon", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.StartPurchase(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/StartPurchase", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.SubtractUserVirtualCurrency(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/SubtractUserVirtualCurrency", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlockContainerInstance(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlockContainerInstance", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UnlockContainerItem(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UnlockContainerItem", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AddFriend(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/AddFriend", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetFriendsList(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetFriendsList", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.RemoveFriend(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/RemoveFriend", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.SetFriendTags(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/SetFriendTags", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetCurrentGames(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetCurrentGames", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetGameServerRegions(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetGameServerRegions", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.Matchmake(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/Matchmake", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.StartGame(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/StartGame", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.WriteCharacterEvent(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/WriteCharacterEvent", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.WritePlayerEvent(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/WritePlayerEvent", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.WriteTitleEvent(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/WriteTitleEvent", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AddSharedGroupMembers(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/AddSharedGroupMembers", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.CreateSharedGroup(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/CreateSharedGroup", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetSharedGroupData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetSharedGroupData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.RemoveSharedGroupMembers(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/RemoveSharedGroupMembers", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdateSharedGroupData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdateSharedGroupData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ExecuteCloudScript(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ExecuteCloudScript", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetContentDownloadUrl(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetContentDownloadUrl", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetAllUsersCharacters(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetAllUsersCharacters", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetCharacterLeaderboard(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetCharacterLeaderboard", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetCharacterStatistics(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetCharacterStatistics", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetLeaderboardAroundCharacter(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetLeaderboardAroundCharacter", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetLeaderboardForUserCharacters(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetLeaderboardForUserCharacters", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GrantCharacterToUser(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GrantCharacterToUser", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdateCharacterStatistics(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdateCharacterStatistics", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetCharacterData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetCharacterData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetCharacterReadOnlyData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetCharacterReadOnlyData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.UpdateCharacterData(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/UpdateCharacterData", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AcceptTrade(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/AcceptTrade", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.CancelTrade(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/CancelTrade", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayerTrades(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayerTrades", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetTradeStatus(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetTradeStatus", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.OpenTrade(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/OpenTrade", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AttributeInstall(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	PlayFabSettings.settings.advertisingIdType = PlayFabSettings.settings.advertisingIdType .. "_Successful"
	IPlayFabHttps.MakePlayFabApiCall("/Client/AttributeInstall", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayerSegments(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayerSegments", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.GetPlayerTags(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/GetPlayerTags", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.AndroidDevicePushNotificationRegistration(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/AndroidDevicePushNotificationRegistration", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.RegisterForIOSPushNotification(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/RegisterForIOSPushNotification", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.RestoreIOSPurchases(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/RestoreIOSPurchases", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ValidateAmazonIAPReceipt(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ValidateAmazonIAPReceipt", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ValidateGooglePlayPurchase(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ValidateGooglePlayPurchase", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ValidateIOSReceipt(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ValidateIOSReceipt", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end





function PlayFabClientApi.ValidateWindowsStoreReceipt(request, onSuccess, onError)
	if not PlayFabClientApi.IsClientLoggedIn() then error("Must be logged in to call this method") end
	IPlayFabHttps.MakePlayFabApiCall("/Client/ValidateWindowsStoreReceipt", request, "X-Authorization", PlayFabSettings._internalSettings.sessionTicket, onSuccess, onError)
end

return PlayFabClientApi