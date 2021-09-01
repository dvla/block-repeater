# frozen_string_literal: true

##
# Additional methods for the Repeater class
#
module RepeaterMethods
  UNTIL_METHOD_REGEX = /until_((.*)_becomes_(.*)|(.*))/.freeze

  ##
  # If a method in the correct format is provided it will be converted into the conditional block for the Repeater class
  # This expects either one or two method names which will be called against the result of repeating the main block.
  # The correct format is 'until_<method name>' or 'until_<method name>_becomes_<method name>'.
  #
  # examples:
  #
  # until_positive?
  # Attempts to call the :positive? method on the result of the block repeat
  #
  # until_count_becomes_positive?
  # Attempts to call :count on the result of the block repeat, then :positive? on that result
  #
  def method_missing(method_name, *args, &block)
    if method_name.match UNTIL_METHOD_REGEX
      @manual_repeat = false
      @unresponsive_errors = []
      first_match = Regexp.last_match(1)
      second_match = Regexp.last_match(2)
      third_match = Regexp.last_match(3)

      if second_match && third_match
        final_result = self.until do |result|
          call_output = call_if_method_responsive(result, second_match)
          call_if_method_responsive(call_output, third_match) if @unresponsive_errors.empty?
        end
      else
        final_result = self.until do |result|
          call_if_method_responsive(result, first_match)
        end
      end
      raise "Methods were not compatible: #{@unresponsive_errors.join(',')}" unless @unresponsive_errors.empty?
      final_result
    else
      super
    end
  end

  def respond_to_missing?(method_name, *)
    method_name.match UNTIL_METHOD_REGEX || super
  end



  # ISSUE: Returns nil instead of the result of the method call
  def call_if_method_responsive(value, method)
    method = method.to_sym
    if value.respond_to?(method)
      value.send(method)
    else
      @unresponsive_errors << "#{value.inspect} of class #{value.class.name} does not respond to method #{method}"
    end
  end
end
