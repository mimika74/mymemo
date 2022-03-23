class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:withdraw]

  def show
    @user = current_user
  end

  def edit
    @user = current_user

    if @user == current_user
      render "edit"
    else
      redirect_to "/"
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)

    redirect_to user_my_page_path
    else
    render :edit
    end
  end


  def unsubscribe
    @user = current_user
  end

  def withdraw
    #user = User.find(params[:id])
    @user = current_user
    @user.destroy
    reset_session
    redirect_to root_path, alert: "ご利用誠にありがとうございました。"

  end

  private

  def user_params
    params.require(:user).permit(:nickname, :email)
  end



end
