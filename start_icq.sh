rvm install ruby-2.7.1
bundle install --without production
export GOOGLE_API_KEY=AIzaSyBCBGVoV8WdLl6y4hTRhwZWZtY8HhhDhVU
export GOOGLE_CLIENT_ID=622662615389-irf3qgbq26dj81psmvctghe2aqk89t26.apps.googleusercontent.com
export GOOGLE_CLIENT_SECRET=I_favhbrUlTbJhUujw6ccwuR
rails db:drop
rails db:migrate
rails db:seed