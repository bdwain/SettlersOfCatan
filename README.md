SettlersOfCatan
===============

## Setup
Clone the repo

copy config/database.yml.example todatabase.yml. fill in your db info. run db:create

copy config/initializers/secret_token.rb.example to secret_token.rb and generate a secret token by following the instructions.

run the server

this does not work on windows yet as the gemfile contains therubyracer, which can't be installed on windows. However, if you'd like to run it on windows, the gemfile just needs to have therubyracer removed, because windows has an alternative.
