class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :expense, dependent: :destroy

  #has_many :favorites, dependent: :destroy

  validates :nickname, {presence:true, length: {minimum:2, maximum: 20}, uniqueness: true}


end
