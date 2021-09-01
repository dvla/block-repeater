# frozen_string_literal: true

require 'block_repeater/repeater_methods'

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
    end

    ##
    # Repeat a block until either the defined timeout is met or the condition block returns true
    #
    # @param times - How many times to attempt to execute the main block
    # @param delay - The amount of time to wait between each attempt
    # @param **_ - Capture any extra keyword arguments and discard them
    # @return The result of calling the main block the final time
    def repeat(times: 25, delay: 0.2, **_)
      result, @condition_met, exception = nil
      times.times do
        result = @repeat_block.call
        begin
          @condition_met = @condition_block.call(result) if @condition_block
          exception = nil
        rescue RSpec::Expectations::ExpectationNotMetError => e
          exception = e
        end
        break if @condition_met

        sleep delay
      end

      raise exception if exception

      result
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
        repeat @repeater_arguments
      end
    end
  end
end
