# frozen_string_literal: true

module PublicLibrary
  class Members < PublicLibrary::Base
    resources :members do
      desc 'Membership details'
      get do
        error!('Not a member', HTTP_CODE[:NOT_FOUND]) unless @current_user.member
        PublicLibrary::Entities::Members.represent(@current_user.member)
      end

      desc 'Member Document Details'
      get '/documents' do
        member = @current_user.member
        error!('Member not found', HTTP_CODE[:NOT_FOUND]) unless member.present?
        PublicLibrary::Entities::MemberDocuments.represent(member)
      end
    end
  end
end
