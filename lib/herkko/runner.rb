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
        Kernel.system("heroku", arguments + ["-r#{environment}"])
      end
    end

    def print_usage
      puts "TODO: Usage instructions"
    end

    def deploy
      puts "Doing deployment to #{environment}"
      if check_travis == :green
        puts "Check if there is migrations to be run in this deployment"
        run_migrations = migrations_needed?
        git_push
        if run_migrations
          migrate
          restart
        end
        # TODO: puts "Check for changes in seed file and remember to run those if present"
        # TODO: puts "Print the after deployment checklist from a file"
      else
        puts "CI is red. Fix it!"
      end
    end

    def check_travis
      puts "Checking CI"
      Herkko::Travis.status_for(current_branch)
    end

    def migrate
      puts "Migrating database"
      Kernel.system("heroku", "migrate", "-r#{environment}")
    end

    def restart
      Kernel.system("heroku", "restart", "-r#{environment}")
    end

    def git_push
      puts "Pushing code"
      Kernel.system("git", "push", environment)
    end

    private

    def current_branch
      Kernel.system("git", "branch")[2..-1]
    end

    def migrations_needed?
      Kernel.system("git", "fetch", environment)
      files = Kernel.system("git", "diff", "--name-only", currently_deployed_to(environment), to_be_deployed_sha)

      files.any? {|filename| filename.match(/db\/migrate/) }
    end

    def currently_deployed_to(environment)
      Kernel.system("git", "rev-parse" "#{environment}/master")
    end

    def to_be_deployed_sha
      Kernel.system("git", "rev-parse", "HEAD")
    end
  end
end
