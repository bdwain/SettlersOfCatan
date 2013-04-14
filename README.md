SettlersOfCatan
===============

## Setup
Set up rails. I followed the instructions [here](https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm), except I used the latest version of ruby

Clone the repo

run "bundle install"

copy config/initializers/secret_token.rb.example to secret_token.rb and generate a secret token by following the instructions.

copy config/database.yml.example to database.yml. fill in your db info. run db:create

copy config/environments/production.rb.example to production.rb. set config.action_mailer.default_url_options to your actual host

run "rails server"

this does not work on windows yet as the gemfile contains therubyracer, which can't be installed on windows. However, if you'd like to run it on windows, the gemfile just needs to have therubyracer removed, because windows has an alternative.
