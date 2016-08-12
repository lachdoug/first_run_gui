require 'sinatra'
require 'rest-client'
require 'json'

get '/' do
  erb :form, layout: :layout
end

post '/submit' do
  if post_first_run_params(params)
    redirect "/complete?local=#{params['local_mgmt'] == 'on'}"
  else
    erb :error, layout: :layout
  end
end

get '/complete' do
  @local_mgmt = params['local_mgmt']
  @api_url = api_url
  @mgmt_url = mgmt_url
  erb :complete, layout: :layout
end

def post_first_run_params(params)
  log "Post submit first run to #{api_url}/v0/system/do_first_run with api_vars: #{{api_vars: params}}"
  result = RestClient.post( "#{api_url}/v0/system/do_first_run", {api_vars: params}.to_json, { content_type: :json } ) == 'true'
  log "Submit first run result: #{result}"
  result
rescue => e
  log "Submit first run error: #{e.inspect}"
  false
end

def mgmt_url
  RestClient.get( "#{api_url}/v0/unauthenticated/bootstrap/mgmt/url" )
rescue => e
  log "System URL error:  #{e.inspect}"
  'Error getting mgmt URL.'
end

def api_url
  ENV['SYSTEM_API_URL'] || "http://127.0.0.1:2380"
end

def log(message)
  p message
end
