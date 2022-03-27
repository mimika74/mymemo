class FavoritesController < ApplicationController
  #before_action :authenticate_user!
  before_action :set_expense, except: :index

  def create
    expense = Expense.find(params[:id])

    #favorite = current_user.favorites.new(expense_id: expense.id)
    #favorite.save
    Favorite.create(expense_id: params[:id])
    #expense_id.user_id = current_user.id
  end

  def destroy
    #expense = Expense.find(params[:id])
    #favorite = current_user.favorites.find_by(expense_id: expense.id)
    #favorite.destroy
    Favorite.find_by(expense_id: params[:id]).destroy
  end


  def index

    #user_id = current_user.id
    #expense2 = Expense.where(user_id: user_id)

    #expense3 = Expense.find_by(expense_id: expense2)


    #@expense = Expense.where(user_id: current_user.id)
    #favorites = Favorite.pluck([:user_id][:expense_id])

    #@favorite_list = Expense.where(user_id: current_user.id).find(Favorite.pluck(:expense_id))
    @favorite_list = Expense.where(user_id: current_user.id).joins(:favorite)

    #redirect_to root_path unless current_user.id == @user

    #favorites = Favorite.pluck(:expense_id)
    #@favorite_list = Expense.find(favorites)
  end

  private
    def set_expense
      @expense = Expense.find(params[:id])
    end

end
