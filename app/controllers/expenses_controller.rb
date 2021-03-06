class ExpensesController < ApplicationController

  before_action :authenticate_user!

  def new
    @expense = Expense.new

  end

  def create
    @expense = Expense.new(expense_params)
    @expense.user_id = current_user.id
    #@expense.genre_id = 1
    if @expense.save
      redirect_to expenses_path
    else
      render :new
    end

  end

  def index

      #@expense.user_id = Expense.current_user.id
      #@expenses = current_user.expenses.all
      #@today = Date.new(year, month, day)today
      @today = Date.today
      if params[:month].present?
        monthSelected = params[:month].split("-")
        year = monthSelected[0].to_i
        month = monthSelected[1].to_i
        @today = Date.new(year, month)
      end
      from_date = Date.new(@today.year, @today.month, @today.beginning_of_month.day).beginning_of_week(:sunday)
      to_date = Date.new(@today.year, @today.month, @today.end_of_month.day).end_of_week(:sunday)
      @calendar_data = from_date.upto(to_date)
      @previous =  Expense.get_previous_month(@today)

      @next = Expense.get_next_month(@today)



      #@expense = Expense.find_by(date: )
      #@expense = Expense.find_by(params[:date])
      #@expenses =Expense.all



  end

  def search
    if params[:search] != ""
      #@expenses =  Expense.where("memo LIKE(?)","%#{params[:search]}%")
      @expenses =  Expense.where(user_id: current_user.id).where("memo LIKE(?)","%#{params[:search]}%")
    else
      #@expenses = Expense.all
      @expenses = current_user.expense.all
    end

  end



  def show


    @date = @calendar_data

    @expense =Expense.find(params[:id])
    #@expense.user_id = current_user.id
    #@expenses = Expense.where(date: @expense.date)
    @expenses = Expense.where(user_id: current_user.id).where(date: @expense.date)

    redirect_to root_path unless current_user.id == @expense.user_id

  end

  def edit
    @expense = Expense.find(params[:id])
    #if @user == current_user
      #render :edit
    #else
      #redirect_to "/"
   # end


  end

  def update
    @expense = Expense.find(params[:id])
    @expense.update(expense_params)
    if @expense.save
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

  def list

    @expenses = current_user.expense.all
  end

  def album

    @expenses = current_user.expense.all
  end

  def aggregate
    #@expense = Expense.select("date").group("date").sum("expense")

    @thisWeekSum =  Expense.where(user_id: current_user.id).where(date: (Date.today - (Date.today.wday))..Date.today).sum(:expense)
    @lastWeekSum =  Expense.where(user_id: current_user.id).where(date: (Date.today - (Date.today.wday) - 7)..(Date.today - (Date.today.wday) - 1)).sum(:expense)
    @monthSum = Expense.where(user_id: current_user.id).where(date: Date.today.beginning_of_month..Date.today.end_of_month).sum(:expense)
    @aggregate = Expense.where(user_id: current_user.id).where(date: Date.today.prev_month.beginning_of_month..Date.today.prev_month.end_of_month).sum(:expense)
  end




  private
    def expense_params
      params.require(:expense).permit(:user_id, :genre_id, :expense, :image, :memo, :target_month, :date)
    end

end
