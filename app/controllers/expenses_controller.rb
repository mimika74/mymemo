class ExpensesController < ApplicationController

  before_action :authenticate_user!

  def new
    @expense = Expense.new

  end

  def create
    @expense = Expense.new(expense_params)
    @expense.user_id = current_user.id

    if @expense.save
      redirect_to expense_path(@expense.id)
    else
      render :new
    end


  end

  def index
    @expenses = current_user.expenses.all
  end

  def edit
    @expense = Expense.find(params[:id])
    if @user == current_user
      render :edit
    else
      redirect_to "/"
    end


  end

  def update
    @expense = Expense.find(params[:id])
    if @expense.update(user_params)
      redirect_to expense_path(@expense.id)
    else
      render :edit
    end
  end

  def destroy
    expense = Expense.find(params[:id])
    expense.destroy
    redirect_to expenses_path
  end

  def show
    @expense =Expense.find(params[:id])
  end

  private
    def expense_params
      params.require(:expense).permit(:user_id, :genre_id, :expense, :image_id, :memo, :target_month)
    end

end
