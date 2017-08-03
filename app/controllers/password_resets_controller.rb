class PasswordResetsController < ApplicationController
  before_action :find_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if user
      create_success
    else
      email_not_found
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      empty_password
    elsif user.update_attributes user_params
      update_success
    else
      render :edit
    end
  end

  private

  attr_reader :user

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def find_user
    @user = User.find_by email: params[:email]

    return if user
    flash[:danger] = t "user.flash.filter.find_user"
    redirect_to root_path
  end

  def valid_user
    return if user && user.activated? && user.authenticated?(
      :reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless user.reset_sent_at < Settings.mail.reset.expire_time
    flash[:danger] = t "flash.pwd_reset.expired"
    redirect_to new_password_reset_url
  end

  def create_success
    user.create_reset_digest
    user.send_password_reset_email
    flash[:info] = t "flash.pwd_reset.create.success"
    redirect_to root_url
  end

  def email_not_found
    flash.now[:danger] = t "flash.pwd_reset.create.email_not_found"
    render :new
  end

  def empty_password
    user.errors.add :password, t("flash.pwd_reset.update.empty_pwd")
    render :edit
  end

  def update_success
    user.update_attributes reset_digest: nil
    log_in user
    flash[:success] = t "flash.pwd_reset.update.success"
    redirect_to user
  end
end
