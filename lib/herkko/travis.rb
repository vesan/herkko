# travis login --pro
# travis history -l1 -bmaster
module Herkko
  class Travis
    def status_for(branch)
      if travis_cli_installed?
        status = fetch_status(branch)
        if status[1].length > 0
          Herkko.info "There was an error with checking Travis: #{status[1]}"
          :red
        else
          if status[0].strip.length == 0
            :not_used
          else
            case status[0].split(":")[0]
            when /passed/
              :green
            when /started/
              :yellow
            when /created/
              :queued
            else
              :red
            end
          end
        end
      else
        Herkko.info "Travis CLI has not been installed, run: gem install travis"
        :unknown
      end
    end

    private

    def fetch_status(branch)
      Herkko.run("travis", "history", "--skip-version-check", "-l", "1", "-b", branch)
    end

    def travis_cli_installed?
      system("which travis > /dev/null 2>&1")
    end
  end
end
