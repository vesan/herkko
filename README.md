# Herkko

Herkko is a deployment tool for Heroku. It's highly opinionated and might not suit your needs. It has certain conventions you need to follow, but it also provides great user experience based on those conventions.

## Installation

Install the gem with:

    $ gem install herkko

## Usage & setup

Herkko requires Travis gem to check the CI status:

    $ gem install travis

Herkko uses the git remote names to identify the applications. Usually you have production and staging.

To set up Heroku remotes:

    $ git remote add production https://git.heroku.com/production-app-name-at-heroku.git
    $ git remote add staging https://git.heroku.com/staging-app-name-at-heroku.git

To deploy current branch to production:

    $ herkko production deploy

Running the command will check Travis CI, deploy if the build is green and runs the migrations after the deployment if commits with migrations were deployed.

## Commands

All commands are run `herkko [environment] [command]` like `herkko staging console`

### deploy

You can add a file in `doc/after_deployment.{md, txt, rdoc, whatever}` and it
will be printed after a succesful deployment.  It can have for example a
checklist like:

* Open the site in the browser and see that it loads.
* Stay alert for a while for exceptions.
* Inform the client if it is needed (Basecamp, email, SMS...)

To put application to maintenance mode while the deployment is running, use flag `--maintenance-mode`.

CI check can be skipped with `--skip-ci-check`.

### console

Open rails console for the application.

### changelog

List of commits to be deployed. Compares the current deployed version and the current local version to see what's been committed.

### seed

Runs seeds.rb.

### migrate

Only runs migrations. This is done automatically on deploy if needed.

## Contributing

1. Fork it ( https://github.com/vesan/herkko/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
