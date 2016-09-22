# Herkko

Herkko is a deployment tool for Heroku. It's highly opinionated and might not suit your needs. It has certain conventions you need to follow, but it also provides great user experience based on those conventions.

## Installation

Install the gem with:

    $ gem install herkko

## Usage

Herkko uses the git remote names to identify the applications. Usually you have production and staging.

TODO: How to setup project for Herkko

## Commands

deploy

You can add a file in `doc/after_deployment.{md, txt, rdoc, whatever}` and it
will be printed after a succesful deployment.  It can have for example a
checklist like:

* Open the site in the browser and see that it loads.
* Stay alert for a while for exceptions.
* Inform the client if it is needed (Basecamp, email, SMS...)

## Contributing

1. Fork it ( https://github.com/vesan/herkko/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
