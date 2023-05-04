# frozen_string_literal: true

require 'block_repeater/repeater_methods'
require 'block_repeater/exception_response'

##
# A way to repeatedly execute a block of code until a given condition is met or a timeout is reached
module BlockRepeater
  ##
  # The class which governs when to stop repeating based on condition or timeout
  class Repeater
    include RepeaterMethods
    @@default_exceptions = []

    ##
    # Prepare the Repeater to take the initial block to be repeated
    #
    # @param manual_repeat - Determines whether the repeat method is called manually, used by the Repeatable module
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
      result, @condition_met, deferred_exception = nil
      anticipated_exception_types = @anticipated_exceptions.map(&:types).flatten
      default_exception_types = @@default_exceptions.map(&:types).flatten
      exception_types = anticipated_exception_types + default_exception_types

      times.times do
        begin
          result = @repeat_block.call
          @condition_met = @condition_block.call(result) if @condition_block
          deferred_exception = nil
        rescue *exception_types => e
          exceptions = if anticipated_exception_types.any? do |ex|
                            e.class <= ex
                          end
                         @anticipated_exceptions
                       else
                         @@default_exceptions
                       end
          matched_response = exceptions.detect { |expected| expected.types.any? { |ex| e.class <= ex } }
          if matched_response.behaviour == :defer
            deferred_exception = matched_response
            deferred_exception.actual = e
          else
            matched_response.execute(e)
          end

          break if matched_response.behaviour == :stop
        end

        break if @condition_met

        sleep delay
      end

      deferred_exception&.execute

      result
    end

    ##
    # Determine how to respond to exceptions raised while repeating, must be called _before_ #until
    #
    # @param &block - Code to execute when an exception is encountered
    # @param exceptions - Which exceptions are being handled by this block, defaults to StandardError
    # @param behaviour - After encountering the exception how should the repeater behave:
    #   :stop     - cease repeating, execute the given block
    #   :continue - execute the given block but keep repeating
    #   :defer    - execute the block only if the exception still occurs after all repeat attempts
    def catch(exceptions: [StandardError], behaviour: :defer, &block)
      @anticipated_exceptions << ExceptionResponse.new(types: exceptions, behaviour: behaviour, &block)
      self
    end

    ##
    # Same as #catch but defines default behaviours shared by all BlockRepeater instances
    # except that there is no default exception type, it must be defined
    def self.default_catch(exceptions: [], behaviour: :defer, &block)
      @@default_exceptions << ExceptionResponse.new(types: exceptions, behaviour: behaviour, &block)
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
        repeat(**@repeater_arguments)
      end
    end
  end
end
