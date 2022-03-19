class FavoritesController < ApplicationController

  before_action :set_expense

  def create
    expense = Expense.find(params[:expense_id])
    favorite = current_user.favorites.new(expense_id: expense.id)
    favorite.save

  end

  def destroy
    expense = Expense.find(params[:expense_id])
    favorite = current_user.favorites.find_by(expense_id: expense.id)
    favorite.destroy

  end


  def index
  end

  private
    def set_expense
      @expense = Expense.find(params[:id])
    end

end
