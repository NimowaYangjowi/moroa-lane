class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(email_address: login_email, password: login_password)
      cookies.delete(:channel_member_logged_out)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    cookies.delete(:_channeltalk_session)
    cookies.permanent[:channel_member_logged_out] = { value: "1", same_site: :lax }
    flash[:channel_logged_out] = true
    redirect_to new_session_path, status: :see_other
  end

  private

  def login_email
    params[:login_email].presence || params[:email_address]
  end

  def login_password
    params[:login_password].presence || params[:password]
  end
end
