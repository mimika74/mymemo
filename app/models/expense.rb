class Expense < ApplicationRecord

  belongs_to :user

  has_one :favorite, dependent: :destroy
  #has_many :aggregates, dependent: :destroy
  attachment :image




  def self.expense_image(date)
    Expense.find_by(date: date).image
  end

  def favorited_by?
    favorite.present?
  end

  def self.get_previous_month(today)
    previous_month = today.month-1
    previous_year = today.year
    if previous_month == 0
      previous_month = 12
      previous_year-=1
    end
    Date.new(previous_year,previous_month)
  end

  def self.get_next_month(today)
    next_month = today.month + 1
    next_year = today.year
    if next_month == 13
      next_month = 1
      next_year+=1
    end
    Date.new(next_year,next_month)
  end



  validates :date, presence:true
  validates :month, presence:true


  #validates :expense, presence: true, if: Proc.new { |expense| expense.image.present? }


  validates :memo, {length: {maximum: 100}}

  #validates :image, presense:true, on: :new
  validates :expense_post, presence: true

  private
    def expense_post
      expense.present? || image.present?
    end





end
