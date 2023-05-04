# frozen_string_literal: true

module BlockRepeater
  ##
  # A nicer way to access the Repeater without setting up the class manually
  module Repeatable
    ##
    # Create an instance of the Repeater class
    #
    # @param **kwargs - Capture all the keyword arguments, pass them into the Repeater
    #   Specifically pass through :times and :delay as others will be ignored
    # @param &block - The block of code to be repeated
    def repeat(**kwargs, &block)
      Repeater.new(manual_repeat: false, **kwargs, &block)
    end
  end
end
