module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def remember user
    user.remember
    cookies_permanent = cookies.permanent
    cookies_permanent.signed[:user_id] = user.id
    cookies_permanent[:remember_token] = user.remember_token
  end

  def current_user
    user_id = session[:user_id]
    user_id_in_cookies = cookies.signed[:user_id]

    if user_id
      @current_user ||= User.find_by id: user_id
    elsif user_id_in_cookies
      remember_user user_id_in_cookies
    end
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  private

  def remember_user user_id
    user = User.find_by id: user_id

    return unless user && user.authenticated?(cookies[:remember_token])
    log_in user
    @current_user = user
  end
end
