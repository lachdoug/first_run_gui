require 'sinatra'
require 'rest-client'
require 'json'

get '/' do
  erb :index, layout: :layout
end

post '/submit' do
  if post_first_run_params(params) && post_close_first_run
    redirect '/startup'
  else
    erb :error, layout: :layout
  end
end

get '/startup' do
  @system_status = system_status
  if @system_status == 'running'
    redirect '/finish'
  end
  erb :startup, layout: :layout
end

get '/finish' do
  @system_status = system_status
  @system_url = system_url
  log "Finished first run, redirect to system URL #{@system_url}"
  erb :finish, layout: :layout
end

def system_status
  RestClient.get( "#{api_url}/v0/unauthenticated/bootstrap/mgmt/state" )
rescue => e
  log "System status error: #{e.inspect}"
  'Error'
end

def system_url
  RestClient.get( "#{api_url}/v0/unauthenticated/bootstrap/mgmt/url" )
rescue => e
  log "System URL error:  #{e.inspect}"
  nil
end

def post_first_run_params(params)
  log "Post submit first run to #{api_url}/v0/system/do_first_run with api_vars: #{{api_vars: params}}"
  result = RestClient.post( "#{api_url}/v0/system/do_first_run", {api_vars: params}.to_json, { content_type: :json } ) == 'true'
  log "Submit first run result #{result}"
  result
rescue => e
  log "Submit first run error: #{e.inspect}"
  false
end

def post_close_first_run
  log "Post close first run to #{api_url}/v0/unauthenticated/bootstrap/first_run/complete"
  result = RestClient.post( "#{api_url}/v0/unauthenticated/bootstrap/first_run/complete" ) == 'true'
  log "Close first run result #{result}"
  result
rescue => e
  log "Close first run error: #{e.inspect}"
  false
end

def api_url
  ENV['SYSTEM_API_URL'] || "http://127.0.0.1:2380"
end

def log(message)
  p message
end
