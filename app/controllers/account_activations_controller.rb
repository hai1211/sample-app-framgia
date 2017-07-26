class AccountActivationsController < ApplicationController
  private

  attr_reader :user

  public

  def edit
    @user = User.find_by email: params[:email]
    flash[:success] = user
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      activate_success
    else
      flash[:danger] = t "flash.activation.invalid_link"
      redirect_to root_url
    end
  end

  private

  def activate_success
    user.activate
    log_in user
    flash[:success] = t "flash.activation.success"
    redirect_to user
  end
end
