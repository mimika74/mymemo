class FavoritesController < ApplicationController

  before_action :set_expense, except: :index

  def create
    expense = Expense.find(params[:id])
    #favorite = current_user.favorites.new(expense_id: expense.id)
    #favorite.save
    Favorite.create(expense_id: params[:id])
  end

  def destroy
    #expense = Expense.find(params[:id])
    #favorite = current_user.favorites.find_by(expense_id: expense.id)
    #favorite.destroy
    Favorite.find_by(expense_id: params[:id]).destroy
  end


  def index

    favorites = Favorite.pluck(:expense_id)
    @favorite_list = Expense.find(favorites)
  end

  private
    def set_expense
      @expense = Expense.find(params[:id])
    end

end
