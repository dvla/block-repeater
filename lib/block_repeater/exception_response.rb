# frozen_string_literal: true

##
# Store an execute behaviour in response to an exception being raised
class ExceptionResponse
  attr_accessor :types, :response, :behaviour, :actual

  BEHAVIOURS = %i[continue stop defer].freeze

  def initialize(types: [], behaviour: :defer, &block)
    raise "Exception handling behaviour '#{behaviour}' not recognised" unless BEHAVIOURS.include? behaviour
    raise 'No exception types provided' if [*types].count.zero?

    @types = [*types]
    @behaviour = behaviour
    @response = block || default_proc
  end

  def execute(exception = nil)
    @response.call(exception || @actual)
  end

  private

  def default_proc
    proc { |e| raise e }
  end
end
