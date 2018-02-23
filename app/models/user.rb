class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :contacts, dependent: :destroy
  has_one  :oauth_token
  has_one  :pushbullet_token, class_name: 'Pushbullet::Token'

  accepts_nested_attributes_for :oauth_token, allow_destroy: true

  def self.from_omniauth(omniauth_auth)
      # ap omniauth_auth
      user_params = {
        email: omniauth_auth.info.email,
        first_name: omniauth_auth.info.first_name,
        last_name: omniauth_auth.info.last_name,
        avatar: omniauth_auth.info.image
      }
      oauth_token_params = {
        token: omniauth_auth.credentials.token,
        expires_at: omniauth_auth.credentials.expires_at,
      }
      if omniauth_auth.credentials.refresh_token
        oauth_token_params[:refresh_token] =  omniauth_auth.credentials.refresh_token
      end

      user_params[:oauth_token_attributes] = oauth_token_params

      user = User.where(email: omniauth_auth.info.email).first
      if user.nil?
        user_params[:password] = Devise.friendly_token[0,20]
        user = User.create(user_params)
      else
        oauth_token_params[:id] = user.oauth_token.try(:id)
        user.update_attributes(user_params)
      end
      user
  end
end
