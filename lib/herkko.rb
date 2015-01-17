require "herkko/version"
require "herkko/runner"

module Herkko
  @@debug = false

  def self.info(text)
    puts "-> " + text
  end

  def self.run(*command)
    if @@debug
      puts "--> #{command.join(" ")}"
    end

    Open3.capture3(*command)
  end

  def self.run_and_puts(*command)
    if @@debug
      puts "--> #{command.join(" ")}"
    end

    Kernel.system(*command)
  end
end
