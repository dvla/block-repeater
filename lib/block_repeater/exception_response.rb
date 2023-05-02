class ExceptionResponse
  attr_accessor :types, :response, :behaviour, :actual
  BEHAVIOURS = [:continue, :stop, :defer]

  def initialize(types: [], behaviour: :defer, &block)
    raise "Exception handling behaviour '#{behaviour}' not recognised" unless BEHAVIOURS.include? behaviour
    raise "No exception types provided" if types.count == 0

    @types = types
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