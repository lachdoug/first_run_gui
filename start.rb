require 'sinatra'
require 'rest-client'
require 'json'

get '/' do
  erb :form, layout: :layout
end

post '/submit' do
  if post_first_run_params(params)
    redirect "/wait?local_mgmt=#{params['local_mgmt'] == 'on'}"
  else
    erb :error, layout: :layout
  end
end

get '/wait' do
  @local_mgmt = params['local_mgmt']
  @mgmt_url = mgmt_url
  erb :wait, layout: :layout
end

get '/complete' do
  if post_complete
    # sleep 99999999999999
    exit
  else
    status 200
  end
end

def post_complete
  log "Post complete first run to #{api_url}v0/unauthenticated/bootstrap/first_run/complete"
  result = RestClient.post( "#{api_url}v0/system/do_first_run", {api_vars: params}.to_json, { content_type: :json } )
  log "Post complete first run result: #{result}"
  result == 'true'
rescue => e
  log "Submit first run error: #{e.inspect}"
  false
end

def post_first_run_params(params)
  log "Post submit first run to #{api_url}v0/system/do_first_run with api_vars: #{{api_vars: params}}"
  result = RestClient.post( "#{api_url}v0/system/do_first_run", {api_vars: params}.to_json, { content_type: :json } ) == 'true'
  log "Submit first run result: #{result}"
  result
rescue => e
  log "Submit first run error: #{e.inspect}"
  false
end

def mgmt_url
  log "Get mgmt_url from #{api_url}v0/unauthenticated/bootstrap/mgmt/url"
  result = RestClient.get( "#{api_url}v0/unauthenticated/bootstrap/mgmt/url" )
  log "Get mgmt_url result: #{result}"
  result
rescue => e
  log "System URL error:  #{e.inspect}"
  'Error getting mgmt URL.'
end

def api_url
  ENV['SYSTEM_API_URL'] || "http://127.0.0.1:2380/"
end

def log(message)
  p message
end
