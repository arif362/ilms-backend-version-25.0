# frozen_string_literal: true
module Lms
  class Passwords < Lms::Base

    resources :passwords do

      desc 'reset password token generate & sent to email'
      params do
        requires :email, type: String, allow_blank: false, regexp: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      end
      route_setting :authentication, optional: true
      post 'sent_token' do
        staff = Staff.library.find_by(email: params[:email])
        error!('Staff not found.', HTTP_CODE[:NOT_FOUND]) unless staff.present?

        staff.send_reset_password_token
        status HTTP_CODE[:OK]
      end

      desc 'Update password by clicking forgot password link'
      params do
        requires :token, type: String
        requires :password, type: String
        requires :password_confirmation, type: String, allow_blank: false,
                                         same_as: { value: :password, message: 'not match' }
      end
      route_setting :authentication, optional: true
      put 'reset' do
        staff = Staff.find_signed!(params[:token], purpose: 'reset password')
        error!('Unauthorized.', HTTP_CODE[:UNAUTHORIZED]) unless staff.present?

        staff.update!(password: params[:password])
        staff.as_json(only: %i[id name email phone])
      end

      desc 'Change password'
      params do
        requires :current_password, type: String, allow_blank: false
        requires :password, type: String, allow_blank: false
        requires :password_confirmation, type: String, allow_blank: false,
                                         same_as: { value: :password, message: 'not match' }
      end

      put '/change_password' do
        error!('User not found', HTTP_CODE[:NOT_FOUND]) if @current_staff.blank?

        unless @current_staff.password == params[:current_password]
          error!('Invalid current password', HTTP_CODE[:BAD_REQUEST])
        end

        error!('Password cannot be blank', HTTP_CODE[:BAD_REQUEST]) if params[:password].blank?
        error!('Password didn\'t match', HTTP_CODE[:BAD_REQUEST]) if params[:password] != params[:password_confirmation]
        if @current_staff.password == params[:password]
          error!('New password can\'t be same as old one', HTTP_CODE[:BAD_REQUEST])
        end

        if @current_staff.update!(password: params[:password], password_confirmation: params[:password_confirmation])
          AuthToken.remove_access_token(@current_staff)
        end
        @current_staff.as_json(only: %i[id name email phone])
      end

    end
  end
end
