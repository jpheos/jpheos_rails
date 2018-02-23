class SynchronizeContacts
  def self.call(user)
    self.new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    contacts_params = GetContactsFromGoogle.call(@user.oauth_token.access_token)
    google_ids = contacts_params.map { |x| x[:google_id] }
    Contact.where.not(google_id: google_ids).destroy_all
    contacts_params.each do |contact_params|
      contact = @user.contacts.find_or_create_by(google_id: contact_params[:google_id])
      contact.update_attributes(
        name:     contact_params[:name],
        birthday: contact_params[:birthday],
        phone:    contact_params[:phone],
        email:    contact_params[:email],
        photo64:  contact_params[:photo]
      )
    end
    nil
  end
end
