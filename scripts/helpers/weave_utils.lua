
WeaveUtils = WeaveUtils or { }

function WeaveUtils.get_rating(score)
	local rating_values = WeaveSettings.rating_values
	local max_rating = 5
	local rating = 0

	if score then
		for i = 1, #rating_values do
			if rating_values [i] < score then
				rating = max_rating - i + 1
				break
			end
		end
	end

	return rating
end