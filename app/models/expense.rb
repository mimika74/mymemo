class Expense < ApplicationRecord

  belongs_to :user
  belongs_to :genre
  has_one :favorite
  attachment :image

end
