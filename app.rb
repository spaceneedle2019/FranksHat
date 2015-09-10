require 'sinatra'

get '/' do
		'Hello, you!'
end

get '/:name' do
		"Hello, #{params[:name]}!"
end
