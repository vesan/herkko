require "herkko/version"
require "herkko/runner"

# Main module of Herkko deployment tool.
module Herkko
  @@debug = false

  def self.info(text)
    Kernel.puts "-> " + text
  end

  def self.puts(text)
    Kernel.puts text
  end

  def self.run(*command)
    if @@debug
      Kernel.puts "--> #{command.join(" ")}"
    end

    Open3.capture3(*command)
  end

  def self.run_with_output(*command)
    command = command.flatten.compact

    if @@debug
      Kernel.puts "--> #{command.join(" ")}"
    end

    Kernel.system(*command)
  end
end
