require 'logger'
module ThreeScaleApi
  module Tools
    class LoggingFactory

      def initialize(log_level: 'debug')
        @log_level = log_level
      end

      # @api public
      # Gets logging logging level number
      # @param [String] log_level Logging level as a string
      # @return [Fixnum] Log level id
      def self.get_level(log_level = 'debug')
        begin
          Logger.const_get log_level.upcase
        rescue NameError
          Logger::DEBUG
        end
      end

      # @api public
      # Creates a instance of logger using in config information
      # @param [String] log_level Override default log level using in config or ENV
      # @return [Logger] Logger instance
      def get_instance(log_level: nil, name: nil)
        logger = Logger.new(STDOUT)
        logger.progname = name if name
        log_level = log_level || @log_level || ENV['LOG_LEVEL'] || 'debug'
        logger.level = LoggingFactory.get_level(log_level)
        logger
      end
    end

    def self.log_factory(log_level: 'debug')
      LoggingFactory.new(log_level: log_level)
    end
  end
end
