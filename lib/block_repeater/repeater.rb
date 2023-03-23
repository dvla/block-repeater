# frozen_string_literal: true

require 'block_repeater/repeater_methods'
require 'rspec/expectations'

##
# A class which repeatedly executes a block of code until a given condition is met or a timeout is reached
#
module BlockRepeater
  class Repeater
    include RepeaterMethods


    ##
    # Prepare the Repeater to take the initial block to be repeated
    #
    # @param manual_repeat - Determines whether the repeat method needs to called manually, used by the Repeatable module
    # @param **kwargs - Capture other arguments in the situation where repeat isn't being called manually
    # @param &block - The block of code to be repeated
    def initialize(manual_repeat: true, **kwargs, &block)
      @manual_repeat = manual_repeat
      @repeater_arguments = kwargs
      @repeat_block = block
      @anticipated_exceptions = []
    end

    ##
    # Repeat a block until either the defined timeout is met or the condition block returns true
    #
    # @param times - How many times to attempt to execute the main block
    # @param delay - The amount of time to wait between each attempt
    # @param **_ - Capture any extra keyword arguments and discard them
    # @return The result of calling the main block the final time
    def repeat(times: 25, delay: 0.2, **_)
      result, @condition_met, rspec_exception = nil
      other_exceptions = @anticipated_exceptions.count > 0 ? @anticipated_exceptions.map{ |eb| eb[:types] }.flatten : []

      times.times do
        begin
          result = @repeat_block.call
          @condition_met = @condition_block.call(result) if @condition_block
          rspec_exception = nil
        rescue ::RSpec::Expectations::ExpectationNotMetError => e
          rspec_exception = e
        rescue *other_exceptions => e
          matched_response = @anticipated_exceptions.detect{ |expected| expected[:types].any? { |exception| e.class <= exception } }
          matched_response[:response].call(e)
          break unless matched_response[:continue]
        end
        break if @condition_met

        sleep delay
      end

      raise rspec_exception if rspec_exception

      result
    end

    def catch(continue: true, exceptions: nil, &block)
      exceptions ||= [StandardError]
      block = proc { |e| puts "Default Handling #{e.class}: #{e}" } unless block_given?
      exception = {
        types: [*exceptions],
        response: block,
        continue: continue
      }
      @anticipated_exceptions << exception
      self
    end

    ##
    # Set the block which determines if the main block should stop being executed
    #
    # @param &block - The block of code which determines the target condition of the main block
    # @return Either return the repeater object if the repeat method is being called manually
    #   or return the result of calling the repeat method
    def until(&block)
      @condition_block = block
      if @manual_repeat
        self
      else
        repeat **@repeater_arguments
      end
    end
  end
end


