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
      return print_usage if environment.nil? || command.nil?

      if respond_to?(command)
        send(command, *arguments)
      else
        Herkko.run_and_puts("heroku", arguments + ["-r#{environment}"])
      end
    end

    def print_usage
      Herkko.info "TODO: Usage instructions"
    end

    def deploy
      Herkko.info "Doing deployment to #{environment}..."
      fetch_currently_deployed_version

      Herkko.info("Deploying changes:")

      puts changelog

      if check_ci == :green
        Herkko.info "CI is green. Deploying..."

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
      else
        Herkko.info "CI is red. Fix it!"
      end
    end

    def check_ci
      Herkko.info "Checking CI..."
      Herkko::Travis.status_for(current_branch)
    end

    def migrate
      Herkko.info "Migrating database..."
      Herkko.run_and_puts %{
        heroku run rake db:migrate -r #{environment} &&
        heroku restart -r #{environment}
      }
    end

    def push_new_code
      Herkko.info "Pushing code to Heroku..."
      Herkko.run_and_puts("git", "push", environment)
    end

    private

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

      files.split("\n").any? {|filename| filename.match(Regex.new(file_path)) }
    end

    def fetch_currently_deployed_version
      Herkko.run_and_puts("git", "fetch", environment)
    end

    def changelog
      Herkko.run("git", "log", "--name-only", "#{currently_deployed_to(environment)}..#{to_be_deployed_sha}")[0]
    end
  end
end
