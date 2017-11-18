require 'sinatra'
require 'rest-client'
require 'json'
require "resolv"

get '/' do
  # @public_ip = Resolv.getaddress('publichost.engines.internal')
  @default_hostname = ENV['HOSTNAME'] || 'engines'
  erb :form, layout: :layout
end

post '/submit' do
  if true || post_first_run_params
    redirect "/complete?local_mgmt=#{form_strong_params[:local_mgmt]}"
  else
    erb :error, layout: :layout
  end
end

get '/complete' do
  @local_mgmt = complete_strong_params[:local_mgmt]
  @mgmt_url = mgmt_url
  @polling_ip = Resolv.getaddress('publichost.engines.internal')
  erb :complete, layout: :layout
end

get '/complete' do
  if post_complete
    sleep 10
  else
    status 400
  end
end

def form_strong_params
  { admin_password: params[:admin_password].to_s,
    # admin_password_confirmation: params[:admin_password_confirmation].to_s,
    # admin_email: params[:admin_email].to_s,
    timezone: params[:timezone].to_s,
    country: params[:country].to_s,
    language: params[:language].to_s,
    hostname: params[:hostname].to_s,
    local_mgmt: params[:local_mgmt].to_s == 'on',
    networking: params[:networking].to_s,
    domain_name: ( params[:domain_name].to_s unless params[:networking] == 'zeroconf' ),
    self_dns_local_only: ( params[:self_dns_local_only].to_s == 'on' if params[:networking] == 'self_hosted_dns' ),
    dynamic_dns_provider: ( params[:dynamic_dns_provider].to_s if params[:networking] == 'dynamic_dns' ),
    dynamic_dns_username: ( params[:dynamic_dns_username].to_s if params[:networking] == 'dynamic_dns' ),
    dynamic_dns_password: ( params[:dynamic_dns_password].to_s if params[:networking] == 'dynamic_dns' ),
    ssl_email: params[:ssl_email].to_s,
    ssl_person_name: params[:ssl_person_name].to_s,
    ssl_organisation_name: params[:ssl_organisation_name].to_s,
    ssl_city: params[:ssl_city].to_s,
    ssl_state: params[:ssl_state].to_s,
    ssl_country: params[:ssl_country].to_s }
end

def complete_strong_params
  { local_mgmt: params[:local_mgmt].to_s == 'true' }
end

def post_first_run_params
  log "Post submit first run to #{api_url}v0/system/do_first_run with api_vars: #{{api_vars: form_strong_params}}"
  result = RestClient.post( "#{api_url}v0/system/do_first_run", {api_vars: form_strong_params}.to_json, { content_type: :json } )
  log "Submit first run result: #{result}"
  result == 'true'
rescue => e
  log "Submit first run error: #{e.inspect}"
  false
end

def post_complete
  log "Post complete first run to #{api_url}v0/unauthenticated/bootstrap/first_run/complete"
  result = RestClient.post( "#{api_url}v0/unauthenticated/bootstrap/first_run/complete", {api_vars: complete_strong_params}.to_json, { content_type: :json } )
  log "Post complete first run result: #{result}"
  log "Post complete first run result class: #{result.class}"
  log "Post complete first run result body: #{result.body}"
  log "Post complete first run result body.length: #{result.body.length}"
  # System returns empty RestClient::Response.body on success.
  result.body == ''
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
  'Error getting mgmt URL'
end

def api_url
  ENV['SYSTEM_API_URL'] || "http://127.0.0.1:2380/"
end

def log(message)
  p message
end
