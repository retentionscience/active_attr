require "active_support/core_ext/string/conversions"
require "active_support/time"

module ActiveAttr
  module Typecasting
    # Typecasts an Object to a DateTime
    #
    # @example Usage
    #   typecaster = DateTimeTypecaster.new
    #   typecaster.call("2012-01-01") #=> Sun, 01 Jan 2012 00:00:00 +0000
    #
    # @since 0.5.0
    class DateTimeTypecaster

      # RS HACK time_zone support
      # ie: attribute :ends_at, :type => DateTime, 
      #       :options => { :time_zone =>  lambda { site.time_zone } }
      def initialize(options = {})
        @time_zone = options.fetch(:time_zone, nil)
      end

      # Typecasts an object to a DateTime
      #
      # Attempts to convert using #to_datetime.
      #
      # @example Typecast a String
      #   typecaster.call("2012-01-01") #=> Sun, 01 Jan 2012 00:00:00 +0000
      #
      # @param [Object, #to_datetime] value The object to typecast
      #
      # @return [DateTime, nil] The result of typecasting
      #
      # @since 0.5.0
      def call(value)
        if value.respond_to? :to_datetime          
          if value.instance_of?(String) && @time_zone # RS HACK time_zone support
            @time_zone.call.parse(value)
          else
            value.to_datetime
          end
        end
      end
    end
  end
end
