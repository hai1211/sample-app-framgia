class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("mail.activation.title")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("mail.pwd_reset.title")
  end
end
