class Aggregate < ApplicationRecord

  belongs_to :user
  belongs_to :expense

  def last_month
    #Date.today.last_month.all_month
    Date.today
  end

end
