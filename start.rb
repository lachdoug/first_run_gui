require 'sinatra'
require 'rest-client'
require 'json'

get '/' do
  erb :index, layout: :layout
end

post '/submit' do
  if submit_to_api(params)
    redirect '/finish'
  else
    erb :error, layout: :layout
  end
end

get '/finish' do
  @system_status = system_status
  if @system_status == 'running'
    @system_url = system_url
  end
  erb :finish, layout: :layout
end

def system_status
  RestClient.get( "#{api_url}/unauthenticated/bootstrap/mgmt/status" )
rescue => e
  p "System ststus error: #{e.response}"
  'Error'
end

def system_url
  RestClient.get( "#{api_url}/unauthenticated/bootstrap/mgmt/url" )
rescue => e
  p "System URL  #{e.response}"
  nil
end

def submit_to_api(params)

p "url #{api_url}/system/do_first_run"
p "api vars #{{api_vars: params}}"

  result = RestClient.post( "#{api_url}/system/do_first_run", {api_vars: params}.to_json, { content_type: :json } ) == 'true'

p "submit result #{result}"

rescue => e
  p "e #{e.response}"
  false
end

def api_url
  ENV['SYSTEM_API_URL'] || "http://127.0.0.1:2380/v0"
end
