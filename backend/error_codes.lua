
ERROR_CODES = { }
BACKEND_LUA_ERRORS = { }
BACKEND_PLAYFAB_ERRORS = { }

if rawget(_G, "Backend") then
	ERROR_CODES [Backend.ERR_OK] = "backend_err_ok"
	ERROR_CODES [Backend.ERR_UNKNOWN] = "backend_err_unknown"
	ERROR_CODES [Backend.ERR_AUTH] = "backend_err_auth"
	ERROR_CODES [Backend.ERR_LOADING_PROFILE] = "backend_err_loading_profile"
	ERROR_CODES [Backend.ERR_TITLE_ID_DISABLED] = "backend_err_title_id_disabled"
	ERROR_CODES [Backend.ERR_COMMIT] = "backend_err_commit"
	ERROR_CODES [Backend.ERR_LOAD_ENTITIES] = "backend_err_load_entities"
	ERROR_CODES [Backend.ERR_SESSION_GENERIC] = "backend_err_session_generic"
	ERROR_CODES [Backend.ERR_SESSION_JOIN] = "backend_err_session_join"
	ERROR_CODES [Backend.ERR_SESSION_LEAVE] = "backend_err_session_leave"
end

BACKEND_LUA_ERRORS.ERR_DISCONNECTED = #ERROR_CODES + 1
ERROR_CODES [BACKEND_LUA_ERRORS.ERR_DISCONNECTED] = "backend_err_disconnected"

BACKEND_LUA_ERRORS.ERR_SIGNIN_TIMEOUT = #ERROR_CODES + 1
ERROR_CODES [BACKEND_LUA_ERRORS.ERR_SIGNIN_TIMEOUT] = "backend_err_signin_timeout"

BACKEND_LUA_ERRORS.ERR_LOADING_PLUGIN = 255
ERROR_CODES [BACKEND_LUA_ERRORS.ERR_LOADING_PLUGIN] = "backend_err_loading_plugin"
BACKEND_LUA_ERRORS.ERR_USE_LOCAL_BACKEND_NOT_ALLOWED = 256
ERROR_CODES [BACKEND_LUA_ERRORS.ERR_USE_LOCAL_BACKEND_NOT_ALLOWED] = "backend_err_use_local_backend_not_allowed"
BACKEND_LUA_ERRORS.ERR_PLATFORM_SPECIFIC_INTERFACE_MISSING = 257
ERROR_CODES [BACKEND_LUA_ERRORS.ERR_PLATFORM_SPECIFIC_INTERFACE_MISSING] = "backend_err_platform_specific_interface_missing"

BACKEND_LUA_ERRORS.ERR_REQUEST_TIMEOUT = #ERROR_CODES + 1
ERROR_CODES [BACKEND_LUA_ERRORS.ERR_REQUEST_TIMEOUT] = "backend_err_request_timeout"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_UNSUPPORTED_VERSION_ERROR = 501
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_UNSUPPORTED_VERSION_ERROR] = "backend_err_playfab_unsupported_version"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_ERROR = 510
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_ERROR] = "backend_err_playfab"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_EAC_ERROR = 511
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_EAC_ERROR] = "backend_err_playfab_eac"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_ACHIEVEMENT_REWARD_CLAIMED = 512
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_ACHIEVEMENT_REWARD_CLAIMED] = "backend_err_achievement_reward_claimed"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_QUEST_REFRESH_UNAVAILABLE = 513
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_QUEST_REFRESH_UNAVAILABLE] = "backend_err_quest_refresh_unavailable"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_COMMIT_TIMEOUT = 514
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_COMMIT_TIMEOUT] = "backend_err_request_timeout"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_NON_FATAL_STORE_ERROR = 515
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_NON_FATAL_STORE_ERROR] = "backend_err_non_fatal_store_error"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_MISSING_REQUIRED_DLC = 516
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_MISSING_REQUIRED_DLC] = "backend_err_missing_required_dlc"

BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_THIRD_PARTY_PROBLEM = 1127
ERROR_CODES [BACKEND_PLAYFAB_ERRORS.ERR_PLAYFAB_THIRD_PARTY_PROBLEM] = "backend_err_3th_party_problem"