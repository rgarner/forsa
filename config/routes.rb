Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'static#home'

  resource :membership_application, only: %i[create show], path: 'membership-application' do
    get 'completed'
    resources :steps, only: %i[show update], controller: 'membership_applications/steps'
  end
end
