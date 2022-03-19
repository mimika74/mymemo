class Favorite < ApplicationRecord
  belongs_to :expense, dependent: :destroy
end