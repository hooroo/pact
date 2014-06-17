require 'rspec'
require 'pact/matchers'
require 'pact/provider/matchers/messages'
require 'pact/rspec'

module Pact
  module RSpec
    module Matchers

      module RSpec2Delegator
        # For backwards compatiblity with rspec-2
        def method_missing(method, *args, &block)
          if method_name == :failure_message_for_should
            failure_message method, *args, &block
          else
            super
          end
        end
      end

      class MatchTerm

        include Pact::Matchers
        include Pact::Matchers::Messages
        include RSpec2Delegator

        def initialize expected
          @expected = expected
        end

        def matches? actual
          @actual = actual
          (@difference = diff(@expected, @actual)).empty?
        end

        def failure_message
          match_term_failure_message @difference, @actual, Pact::RSpec.color_enabled?
        end

      end

      def match_term expected
        MatchTerm.new(expected)
      end

      class MatchHeader

        include Pact::Matchers
        include Pact::Matchers::Messages
        include RSpec2Delegator

        def initialize header_name, expected
          @header_name = header_name
          @expected = expected
        end

        def matches? actual
          @actual = actual
          diff(@expected, @actual).empty?
        end

        def failure_message
          match_header_failure_message @header_name, @expected, @actual
        end

      end

      def match_header header_name, expected
        MatchHeader.new(header_name, expected)
      end

    end
  end
end


# RSpec::Matchers.define :match_header do |header_name, expected|

#   include Pact::Matchers
#   include Pact::Matchers::Messages

#   match do |actual|
#     diff(expected, actual).empty?
#   end

#   def failure_message_for_should(actual)
#     match_header_failure_message header_name, expected, actual
#   end

#   # failure_message_for_should do | actual |
#   #   match_header_failure_message header_name, expected, actual
#   # end

# end