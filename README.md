SettlersOfCatan
===============

## Setup
Set up ruby 2.0.0p0 and rubygems. I used rvm and followed the instructions [here](https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm), except I used ruby 2.0.0p0. 

Clone the repo

The next step allows bundler to install all of the necessary mysql files. You can use another database, but those are in the gemfile. 

    sudo apt-get install libmysqld-dev libmysqlclient-dev mysql-client
  

Run "bundle install"

Copy config/application.yml.example to config/application.yml and set all of the values

Copy config/database.yml.example to database.yml and fill in your db info. 

Rake db:create and rake db:schema:load

Run the server

## Other

To generate a pdf of the model, you need to install the package [graphviz](http://rails-erd.rubyforge.org/install.html).
Then you can run "rake erd" to generate a pdf

This does not work on windows yet as the gemfile contains therubyracer, which can't be installed on windows. 
However, if you'd like to run it on windows, the gemfile just needs to have therubyracer removed, because windows has an alternative.
