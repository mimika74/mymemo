class Expense < ApplicationRecord

  belongs_to :user
  belongs_to :genre
  has_one :favorite
  attachment :image


  def self.expense_image(date)
    Expense.find_by(date: date).image
  end



end
