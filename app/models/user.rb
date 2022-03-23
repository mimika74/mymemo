class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :expense, dependent: :destroy
  has_many :aggregate, dependent: :destroy
  #has_one :favorite, dependent: :destroy




end
