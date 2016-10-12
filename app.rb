require 'sinatra'  # Rails or Hanami port may be added
require 'httparty' # HTTP connections \m/
require 'json'	   # Woo, data!

#So, what we will do is have Roxy take note when she is mentioned
#in a slack message. Slack will send the details of the message
#and other necessary details. We will use a POST with the data in the body of the message
#Then we will fetch the message and respond.

post '/gateway' do #handles requests from slack
	message = params[:text].gsub(params[:trigger],'').strip

	action, repo = message.split('_').map {
		|i| i.strip.downcase
	}

	#utilize the github api to call Roxy
	repo_url = "https://api.github.com/repos/#{repo}"

	# Currently, the only available action call will be
	# 'issues' which will fetch the issues of a repo
	# In the future, I will be adding:
	# Forks
	# Stars
	# Latest Commit info
	# Giving Roxy some personality
	# Letting Roxy e-mail information about her chat interactions
	# Scheduling messages/announcements
	case action
		when 'issues'
			resp = HTTParty.get(repo_url)
			resp = JSON.parse resp.body
			response "There are #{resp['open_issues_count']} open issues on #{repo}"
		end
	end

	def response message
		content_type :json
		{:text => message}.to_json
	end
end