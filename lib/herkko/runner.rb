require "herkko/travis"
require "open3"

module Herkko
  class Runner
    attr_reader :environment, :command, :arguments

    def initialize(argv)
      argv.dup.tap do |arguments|
        @environment = arguments.shift
        @command = arguments.shift
        @arguments = arguments unless arguments.empty?
      end
    end

    def run
      if ["version", "--version"].include?(environment)
        return print_version
      end

      if ["help", "--help"].include?(environment)
        return print_usage
      end

      return print_usage if environment.nil? || command.nil?

      if respond_to?(command)
        send(command)
      else
        Herkko.run_with_output("heroku", command, arguments, "-r#{environment}")
      end
    end

    def print_version
      Herkko.puts "Herkko #{Herkko::VERSION}"
    end

    def print_usage
      Herkko.puts <<END
# Herkko

Run `herkko [remote name] [command]` for example `herkko production deploy`.

There are special commands like `deploy` is a special command that does extra checks. Other commands 
are just proxied to the heroku CLI tool (for example `herkko production logs`).

## Naming remotes

It's recommended to name your remotes for example production & staging. Then you can always just type `herkko production deploy` to release a new version.

## Commands

console   | Opens Rails console
deploy    | Deploys new version
seed      | Runs seeds.rb
migrate   | Run migrations and restarts the app
changelog | Prints the commits to be deployed

### deploy

--skip-ci-check - Skips the Travis CI build status check

END
    end

    def changelog
      fetch_currently_deployed_version
      puts git_changelog
    end

    def deploy
      Herkko.info "Doing deployment to #{environment}..."
      fetch_currently_deployed_version

      Herkko.info("Deploying changes:")

      puts
      puts git_changelog
      puts

      ci_state = if skip_ci_check?
        :skip
      else
        check_ci
      end

      if ci_state == :green
        Herkko.info "CI is green. Deploying..."

        deploy!
      elsif ci_state == :skip
        Herkko.info "Skipping CI. Deploying..."

        deploy!
      elsif ci_state == :not_used
        Herkko.info "CI not in use for this project. Deploying..."

        deploy!
      elsif ci_state == :yellow
        Herkko.info "CI is running. Wait a while."
      else
        Herkko.info "CI is in unknown state. Can't continue."
      end
    end

    def console
      Herkko.run_with_output "heroku run rails console -r #{environment}"
    end

    def seed
      Herkko.run_with_output "heroku run rake db:seed -r #{environment}"
    end

    def migrate
      Herkko.info "Migrating database..."
      Herkko.run_with_output %{
        heroku run rake db:migrate -r #{environment} &&
        heroku restart -r #{environment}
      }
    end

    def push_new_code
      Herkko.info "Pushing code to Heroku..."
      puts
      Herkko.run_with_output("git", "push", environment, "master")
      puts
    end

    private

    def check_ci
      Herkko.info "Checking CI..."

      travis_client.status_for(current_branch)
    end

    def deploy!
      run_migrations = migrations_needed?
      push_new_code

      if run_migrations
        migrate
      else
        Herkko.info "No need to migrate."
      end

      if seed_file_changed?
        Herkko.info "NOTE: Seed file seem the have changed. Make sure to run it if needed."
      end

      # TODO: puts "Print the after deployment checklist from a file"
    end

    def skip_ci_check?
      arguments && arguments.include?("--skip-ci-check")
    end

    def current_branch
      Herkko.run("git", "rev-parse", "--abbrev-ref", "HEAD")[0].strip
    end

    def migrations_needed?
      file_changed?("db/migrate")
    end

    def seed_file_changed?
      file_changed?("db/seeds.rb")
    end

    def currently_deployed_to(environment)
      Herkko.run("git", "rev-parse", "#{environment}/master")[0].strip
    end

    def to_be_deployed_sha
      Herkko.run("git", "rev-parse", "HEAD")[0].strip
    end

    def file_changed?(file_path)
      files = Herkko.run("git", "diff", "--name-only", currently_deployed_to(environment), to_be_deployed_sha)[0]

      files.split("\n").any? {|filename| filename.match(Regexp.new(file_path)) }
    end

    def fetch_currently_deployed_version
      Herkko.run_with_output("git", "fetch", environment)
    end

    def git_changelog
      Herkko.run("git", "log", "--pretty=format:%C(yellow)%h %Cblue%ad%Creset %an %Cgreen%s%Creset", "--date=short", "#{currently_deployed_to(environment)}..#{to_be_deployed_sha}")[0]
    end

    def travis_client
      @travis_client ||= Herkko::Travis.new
    end
  end
end
