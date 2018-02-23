class ContactsController < ApplicationController
  def index
    @contacts = current_user.contacts.sort { |x, y| x.nb_days_before_next_birthday <=> y.nb_days_before_next_birthday }
    @token = current_user.oauth_token.access_token
  end

  def synchronization
    SynchronizeContacts.call(current_user)
    flash[:notice] = "Les contacts ont était synchronisés!"
    redirect_back(fallback_location: root_path)
  end

end
