task :synchro_contacts => :environment do
  User.all.each do |user|
    SynchronizeContacts.call(user)
  end
end

