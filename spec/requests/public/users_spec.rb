require 'rails_helper'

RSpec.describe 'Public::Users', type: :request do
  describe 'Register new user test' do
    it 'Register user' do

      post '/public_library/users',
           headers: @default_headers,
           params: {
             full_name: 'New User',
             phone: '01900998888',
             gender: 'male',
             dob: '1995-02-17',
             # email:email3@gmail.com
           }
      puts response.body
      expect(response).to have_http_status(201)
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts e.backtrace.join("\n")
      raise e

    end
  end
end
