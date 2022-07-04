# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  protected

  def after_sign_out_path_for(_resource)
    root_path
  end

  def after_sign_in_path_for(_resource)
    user_path(current_user)
  end
end
