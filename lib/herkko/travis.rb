# travis login --pro
# travis history -l1 -bmaster
module Herkko
  class Travis
    def self.status_for(branch)
      status = fetch_status(branch)
      if status[1].length > 0
        Herkko.info "There was an error with checking Travis: #{status[1]}"
        :red
      else
        case status[0].split(":")[0]
        when /passed/
          :green
        when /started/
          :yellow
        else
          :red
        end
      end
    end

    private

    def self.fetch_status(branch)
      Herkko.run("travis", "history", "--skip-version-check", "-l", "1", "-b", branch)
    end
  end
end
