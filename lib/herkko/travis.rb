# travis login --pro
# travis history -l1 -bmaster
module Herkko
  class Travis
    def self.status_for(branch)
      if Kernel.system("travis", "history" "-l", "1" "-b", branch).match(/passed/)
        :green
      else
        :red
      end
    end
    # uri = URI.parse("https://api.travis-ci.com/kiskolabs/WODConnect.png?token=5Yx9a66z5x2yJUZW5Aei&branch=master")
    #
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #
    # request = Net::HTTP::Head.new(uri.request_uri)
    #
    # response = http.request(request)
    #
    # if (response.code == "200")
    #   content_disposition = response["Content-Disposition"]
    #   if content_disposition =~ /passing/
    #     puts "Build is green at Travis"
    #   elsif content_disposition =~ /failing/
    #     abort "The build is red in Travis. https://magnum.travis-ci.com/kiskolabs/WODConnect (in emergency use FAST=true to skip the check)"
    #   else
    #     abort "The build status is unknown in Travis. https://magnum.travis-ci.com/kiskolabs/WODConnect (or in emergency use FAST=true to skip the check)"
    #   end
    # else
    #   abort "The build status is unknown in Travis. https://magnum.travis-ci.com/kiskolabs/WODConnect (or in emergency use FAST=true to skip the check)"
    # end
  end
  end
end
