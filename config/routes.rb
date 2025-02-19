Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount Admin::Base => '/'
  mount PublicLibrary::Base => '/'
  mount Lms::Base => '/'
  mount ThreePs::Base => '/'

end
