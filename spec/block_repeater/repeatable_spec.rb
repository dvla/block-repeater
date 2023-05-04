# frozen_string_literal: true

RSpec.describe BlockRepeater::Repeatable do
  include BlockRepeater::Repeatable
  include RepeaterMethods

  describe '#repeat' do
    it 'returns once the exit condition is met' do
      result = 0
      repeat { result += 1 }.until { result == 10 }
      expect(result).to eql(10)
    end

    it 'does not return early if the exit condition is not met' do
      result = 0
      repeat(times: 10) { result += 1 }.until { result == 0 }
      expect(result).to eql(10)
    end

    it 'can pass the value of the main block between methods' do
      result = 0
      repeat { result += 1 }.until { |output| output == 5 }
      expect(result).to eql(5)
    end

    it 'only repeats the specified number of times' do
      result = 0
      repeat(times: 5) { result += 1 }.until { result == 10 }
      expect(result).to eql(5)
    end
  end

  describe '#until_<method_name>' do
    it 'successfully calls the #positive method on a integer response' do
      result = 0
      repeat { result += 1 }.until_positive?
      expect(result).to eql(1)
    end

    it 'throws an appropriate error when the #positive method is called on a string response' do
      expect { repeat { 'a string' }.until_positive? }.to raise_exception RepeaterMethods::MethodUnresponsiveError
    end
  end

  describe '#until_<method_name>_becomes_<method_name>' do
    it 'successfully calls the #count and #zero methods on an array response' do
      result = [1, 2, 3, 4, 5]
      repeat do
        result.pop
        result
      end.until_count_becomes_zero?
      expect(result.count).to be_zero
    end

    it 'throws an appropriate error when a valid and invalid method are called a string response' do
      expect do
        repeat do
          'a string'
        end.until_upcase_becomes_positive?
      end.to raise_exception RepeaterMethods::MethodUnresponsiveError
    end

    it 'throws an appropriate error when two invalid methods are called a string response' do
      expect do
        repeat do
          'a string'
        end.until_not_a_method_becomes_positive?
      end.to raise_exception RepeaterMethods::MethodUnresponsiveError
    end
  end

  describe '#catch' do
    it 'will excute code triggerred a specific defined exception' do
      triggered = false

      repeat(times: 3) { raise IOError }
        .catch(exceptions: [IOError]) { triggered = true }
        .until { true }

      expect(triggered).to be_truthy
    end

    it 'will allow repetition attempts to finish if the behaviour is defined as :contine ' do
      attempts = 0
      catches = 0

      repeat(times: 3) do
        attempts += 1
        raise NameError
      end
        .catch(exceptions: NameError, behaviour: :continue) { catches += 1 }
        .until { true }

      expect(attempts).to eq 3
      expect(catches).to eq 3
    end

    it 'will execute the block only after all attempts have been made if the behaviour is defined as :defer ' do
      attempts = 0
      catches = 0

      repeat(times: 3) do
        attempts += 1
        raise NameError
      end
        .catch(exceptions: NameError, behaviour: :defer) { catches += 1 }
        .until { true }

      expect(attempts).to eq 3
      expect(catches).to eq 1
    end

    it 'will execute the block and prevent further attempts if the behaviour is defined as :stop ' do
      attempts = 0
      catches = 0

      repeat(times: 3) do
        attempts += 1
        raise NameError
      end
        .catch(exceptions: NameError, behaviour: :stop) { catches += 1 }
        .until { true }

      expect(attempts).to eq 1
      expect(catches).to eq 1
    end

    it 'will execute code triggered by a later exception in the chain' do
      triggered = false

      repeat(times: 3) { raise IOError }
        .catch(exceptions: [NameError]) { triggered = false }
        .catch(exceptions: [IOError]) { triggered = true }
        .until { true }

      expect(triggered).to be_truthy
    end

    it 'will execute code triggered by a child of a defined exception' do
      triggered = false

      repeat(times: 3) { raise IOError }
        .catch(exceptions: [StandardError]) { triggered = true }
        .until { true }

      expect(triggered).to be_truthy
    end

    it 'will not execute code if a non-defined exception has been thrown' do
      expect do
        repeat(times: 3) { raise IOError }
          .catch(exceptions: [NameError]) { nil }
          .until { true }
      end.to raise_exception IOError
    end
  end

  describe '#default_catch' do
    it 'allows pre-defined exception handling logic to apply without calling #catch' do
      result = nil
      BlockRepeater::Repeater.default_catch(exceptions: ThreadError, behaviour: :defer) do
        result = 'Default logic triggered'
      end

      repeat(times: 3) { raise ThreadError }
        .until { true }

      expect(result).to eq 'Default logic triggered'
    end

    it 'lets default logic be ignored in favour of specific logic' do
      result = nil
      BlockRepeater::Repeater.default_catch(exceptions: ThreadError, behaviour: :defer) do
        result = 'Default logic triggered'
      end

      repeat(times: 3) { raise ThreadError }
        .catch(exceptions: ThreadError) { result = 'Non-default logic triggered' }
        .until { true }

      expect(result).to eq 'Non-default logic triggered'
    end
  end
end
