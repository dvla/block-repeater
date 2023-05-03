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

  describe('#until_<method_name>') do
    it 'successfully calls the #positive method on a integer response' do
      result = 0
      repeat { result += 1 }.until_positive?
      expect(result).to eql(1)
    end

    it 'throws an appropriate error when the #positive method is called on a string response' do
      expect { repeat { 'a string' }.until_positive? }.to raise_exception RepeaterMethods::MethodUnresponsiveError
    end
  end

  describe('#until_<method_name>_becomes_<method_name>') do
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
end
