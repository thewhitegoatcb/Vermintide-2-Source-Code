NewsTickerToken = NewsTickerToken or class()

function NewsTickerToken:init(loader, job)
	self._loader = loader
	self._job = job
end

function NewsTickerToken:info()
	if self:done() and UrlLoader.success(self._loader, self._job) then
		return UrlLoader.text(self._loader, self._job)
	else
		return "Failed loading news ticker"
	end
end

function NewsTickerToken:update()
	return end

function NewsTickerToken:done()
	return UrlLoader.done(self._loader, self._job)
end

function NewsTickerToken:close()
	UrlLoader.unload(self._loader, self._job)
end