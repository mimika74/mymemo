class Favorite < ApplicationRecord

  belongs_to :expense, dependent: :destroy
  belongs_to :user




end