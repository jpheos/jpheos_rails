class Contact < ApplicationRecord
  include ContactBirthday

  belongs_to :user
end
