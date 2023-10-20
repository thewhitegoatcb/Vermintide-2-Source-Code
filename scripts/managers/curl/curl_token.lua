CurlToken = class(CurlToken)

function CurlToken:init(token)
	self._token = token
	self._info = { }

	if not token then
		self._info.done = true
		self._info.error = "Not a valid token"
	end
end

function CurlToken:info()
	return self._info
end

function CurlToken:update()
	if self._token then
		self._info = Curl.progress(self._token)
	end
end

function CurlToken:done()
	return self._info.done
end

function CurlToken:close()
	if self._token then
		Curl.close(self._token)
	end
end