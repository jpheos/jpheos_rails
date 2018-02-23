class Pushbullet::OauthController < ApplicationController

  def connect
    @client = OAuth2::Client.new(ENV['PUSHBULLET_CLIENT_ID'], ENV['PUSHBULLET_CLIENT_SECRET'], :authorize_url => 'https://www.pushbullet.com/authorize')
    auth_url = @client.auth_code.authorize_url(:redirect_uri => pushbullet_callback_url)
    redirect_to auth_url
  end

  def callback
    @client = OAuth2::Client.new(ENV['PUSHBULLET_CLIENT_ID'], ENV['PUSHBULLET_CLIENT_SECRET'], :token_url => 'https://api.pushbullet.com/oauth2/token')
    token = @client.auth_code.get_token(params[:code], :redirect_uri => pushbullet_callback_url)
    pushbullet_token = (current_user.pushbullet_token || current_user.build_pushbullet_token)
    pushbullet_token.access_token = token.token
    pushbullet_token.save!
    redirect_to pushbullet_select_device_path
  end

  def select_device_form
    client = PushbulletRuby::Client.new(current_user.pushbullet_token.access_token)
    @devices = client.devices.map {|d| {id: d.id, name: d.name}}
  end

  def select_device
    current_user.pushbullet_token.update_attributes(device: params[:device_id])
    flash[:notice] = "Device Pushbullet bien mis à jour."
    redirect_to root_path
  end

end
