Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "courses#index"
  resources :courses, :only => [:index, :show] do
    resources :questions, :only => [:index, :new, :create, :destroy] do
      resources :polls, :only => [:index, :show, :create, :update, :destroy] do
        resources :poll_responses, :only => [:create]
      end
    end
  end
  get '/courses/:course_id/questions/:question_id/polls/:id/status', :to => 'polls#status', :as => :poll_status, :action => 'status', :controller => 'polls'
  get '/courses/:id/attendance_report', :to => 'courses#attendance_report', :as => :attendance_report, :action => "attendance_report", :controller => 'courses'
  get '/courses/:id/question_report', :to => 'courses#question_report', :as => :question_report, :action => "question_report", :controller => 'courses'
  get '/courses/:id/status', :to => 'courses#status', :as => :course_status, :action => 'status', :controller => 'courses'
  get '/polls/:id/notify', :to => 'polls#notify', :as => :poll_notify, :action => 'notify', :controller => 'polls'
  post '/courses/:course_id/take_attendance', :to => 'courses#take_attendance', :as => :course_attendance, :action => 'take_attendance', :controller => 'courses'
  post '/courses/:id/attendance_report/cold_call', :to => 'courses#cold_call', :as => :cold_call, :action => 'cold_call', :controller => 'courses'
  
  get '/x', :to => 'courses#create_and_activate'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
