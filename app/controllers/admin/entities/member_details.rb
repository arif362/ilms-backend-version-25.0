# frozen_string_literal: true

module Admin
  module Entities
    class MemberDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers
      format_with(:iso_date, &:to_date)

      expose :id
      expose :unique_id, as: :member_id
      expose :full_name
      expose :phone
      expose :email
      expose :gender
      expose :dob, format_with: :iso_date
      expose :identity_type
      expose :identity_number
      expose :father_Name
      expose :mother_name
      expose :present_address
      expose :permanent_address
      expose :profession
      expose :institute_name
      expose :library
      expose :membership_details
      expose :membership_details
      expose :current_fine
      expose :borrowed_books
      expose :images

      def present_address
        {
          address: object&.present_address,
          thana: object&.present_thana&.name,
          district: object&.present_district&.name,
          division: object&.present_division&.name
        }
      end

      def permanent_address
        {
          address: object&.permanent_address,
          thana: object&.permanent_thana&.name,
          district: object&.permanent_district&.name,
          division: object&.permanent_division&.name
        }
      end
      def library
        library = Library.find_by(id: object&.library_id)
        {
          "id": library.id,
          "library_code": library.code
        }
      end

      def full_name
        user&.full_name
      end

      def gender
        user&.gender
      end

      def dob
        user&.dob
      end

      def phone
        user&.phone
      end

      def user
        object&.user
      end

      def membership_details
        {
          membership_category: object&.membership_category,
          expire_date: object&.expire_date&.strftime('%Y-%m-%d'),
          activation_date: object&.activated_at&.strftime('%Y-%m-%d'),
          total_borrowed_books: member_borrowed_books.count
        }
      end

      def borrowed_books
        Admin::Entities::MemberBorrowList.represent(member_borrowed_books)
      end

      def member_borrowed_books
        object.circulations.where(circulation_status_id: CirculationStatus.get_status(CirculationStatus.status_keys[:borrowed]))
      end

      def current_fine
        borrow_fine = 0
        member_borrowed_books.each do |borrowed_book|
          borrow_fine += borrowed_book.calculate_fine
        end
        invoice_fine = user.invoices.fine.where.not(invoice_status: :paid).sum(&:invoice_amount)
        borrow_fine + invoice_fine
      end

      def images
        {
          profile_image: image_path(object&.profile_image),
          nid_front_image: image_path(object&.nid_front_image),
          nid_back_image: image_path(object&.nid_back_image),
          birth_certificate_image: image_path(object&.birth_certificate_image),
          student_id_image: image_path(object&.student_id_image),
          verification_certificate_image: image_path(object&.verification_certificate_image)
        }
      end
    end
  end
end
