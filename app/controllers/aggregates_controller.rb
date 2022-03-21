class AggregatesController < ApplicationController
  def index
    #@expense = Expense.select("date").group("date").sum("expense")

    @thisWeekSum =  Expense.where(date: (Date.today - (Date.today.wday))..Date.today).sum(:expense)
    @lastWeekSum =  Expense.where(date: (Date.today - (Date.today.wday) - 7)..(Date.today - (Date.today.wday) - 1)).sum(:expense)
    @monthSum = Expense.where(date: Date.today.beginning_of_month..Date.today.end_of_month).sum(:expense)
    @aggregate = Expense.where(date: Date.today.prev_month.beginning_of_month..Date.today.prev_month.end_of_month).sum(:expense)
  end

  def create
  end

  def update
  end
end
