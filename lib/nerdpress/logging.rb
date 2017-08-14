require 'logger'
require 'pathname'

require_relative './util/multi_io.rb'

module NerdPress
  module Logger
    DEFAULT_LEVEL = ::Logger::DEBUG

    def self.setup(log_dir: nil, log_level: DEFAULT_LEVEL)
      $stdout.sync = true
      io = $stdout

      if log_dir
        log_dir_path = Pathname.new(log_dir)
        log_dir_path.mkpath unless log_dir_path.exist?

        log_file_path = log_dir_path.join('build.log')
        log_file = log_file_path.open(File::WRONLY | File::APPEND | File::CREAT)

        log_file.sync = true

        io = MultiIO.new($stdout, log_file)
      end

      @instance = ::Logger.new(io, level: log_level)
    end

    def self.instance
      @instance
    end
  end

  module Logging
    def logger
      NerdPress::Logger.instance
    end

    %w( debug error fatal info unknown warn ).each do |severity|
      define_method(severity) do |message|
        logger.send(severity, message)
      end
    end
  end
end
