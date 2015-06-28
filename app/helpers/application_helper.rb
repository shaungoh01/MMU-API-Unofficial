module ApplicationHelper
	def tilte
		base_title = "MMU HUB"
		if @title.nil?
			base_title
		else
			"#{base_title} - #{@title}"
		end
	end	
end
