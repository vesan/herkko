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
        if status[0].match(/passed/)
          :green
        else
          :red
        end
      end
    end

    private

    def self.fetch_status(branch)
      Herkko.run("travis", "history", "-l", "1", "-b", branch)
    end
  end
end
