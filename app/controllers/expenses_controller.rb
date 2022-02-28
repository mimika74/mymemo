class ExpensesController < ApplicationController

  before_action :authenticate_user!

  def new
    @expense = Expense.new

  end

  def create
    @expense = Expense.new(expense_params)
    @expense.user_id = current_user.id
    @expense.genre_id = 1
    @expense.save!
      redirect_to expenses_path

  end

  def index
    #@expenses = current_user.expenses.all

    @today = Date.today
    from_date = Date.new(@today.year, @today.month, @today.beginning_of_month.day).beginning_of_week(:sunday)
    to_date = Date.new(@today.year, @today.month, @today.end_of_month.day).end_of_week(:sunday)
    @calendar_data = from_date.upto(to_date)

    #@expense = Expense.find_by(date: )
    @expense = Expense.find_by(params[:date])
    @expenses =Expense.all
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
      params.require(:expense).permit(:user_id, :genre_id, :expense, :image, :memo, :target_month, :created_at, :updated_at, :date)
    end

end