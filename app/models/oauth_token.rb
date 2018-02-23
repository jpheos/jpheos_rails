class OauthToken < ApplicationRecord
  belongs_to :user

  CLIENT_OPTS = {
    site: 'https://accounts.google.com',
    authorize_url: '/o/oauth2/auth',
    token_url: '/o/oauth2/token'
  }

  CLIENT = OAuth2::Client.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], CLIENT_OPTS)

  def access_token
    if (token.blank? || expires_at.blank? || access_token_object.expired?)
      new_access_token_object = access_token_object.refresh!
      self.token          = new_access_token_object.token
      self.refresh_token  = new_access_token_object.refresh_token
      self.expires_at     = new_access_token_object.expires_at
      self.save!
    end
    token
  end

  private

  def access_token_object
    OAuth2::AccessToken.new(CLIENT, token, opts = {refresh_token: refresh_token, expires_at: expires_at})
  end

end
