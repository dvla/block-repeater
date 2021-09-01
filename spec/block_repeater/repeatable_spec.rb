RSpec.describe BlockRepeater::Repeatable do
  include BlockRepeater::Repeatable

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
      repeat(times: 5) { result += 1 }.until{ result == 10 }
      expect(result).to eql(5)
    end

    # test expectation doesn't fail before final test
    # test metaprogrammed methods (until and until_becomes)
  end
end