module SessionsHelper

  def sign_in(user)
    cookies.permanent.signed[:token] = [user.id, user.salt]
    current_user = user
  end

  def sign_out
    cookies.delete(:token)
    current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_token
  end

  def signed_in?
    !current_user.nil?
  end

  private

  def user_from_token
    User.authenticate_with_salt *token
  end

  def token
    cookies.signed[:token] || [nil, nil]
  end
end
