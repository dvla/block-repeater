# frozen_string_literal: true

RSpec.describe BlockRepeater::Repeater do
  subject { described_class }

  describe '#repeat' do
    it 'repeats 25 times if no repeat value is specified' do
      result = 0
      subject.new do
        result += 1
      end.repeat
      expect(result).to eql(25)
    end

    it 'repeats a specific number times if a repeat value is specified' do
      result = 0
      subject.new do
        result += 1
      end.repeat(times: 10)
      expect(result).to eql(10)
    end
  end

  describe '#until' do
    it 'returns once the exit condition is met' do
      result = 0
      subject.new do
        result += 1
      end.until do
        result == 10
      end.repeat(times: 50)
      expect(result).to eql(10)
    end

    it 'does not return early if the exit condition is not met' do
      result = 0
      subject.new do
        result += 1
      end.until do
        result == 0
      end.repeat(times: 10)
      expect(result).to eql(10)
    end

    it 'can pass the value of the main block between methods' do
      result = 0
      subject.new do
        result += 1
      end.until do |output|
        output == 5
      end.repeat
      expect(result).to eql(5)
    end
  end

  describe '#backoff' do
    # 0.1 with a multiple of 2 should run 8 times in total
    it 'repeats 8 times if default values are used' do
      result = 1
      subject.new do
        result += 1
      end.backoff
      expect(result).to eql(8)
    end

    it 'repeats x times if custom values are used' do
      result = 1
      subject.new do
        result += 1
      end.backoff(timeout: 20, initial_wait: 1)
      expect(result).to eql(6)
    end

    it 'returns once the condition is met' do
      result = 0
      subject.new do
        result += 1
      end.until do |output|
        output == 3
      end.backoff
      expect(result).to eql(3)
    end

    it 'does not return early if the exit condition is not met' do
      result = 1
      subject.new do
        result += 1
      end.until do
        result == 0
      end.backoff
      expect(result).to eql(8)
    end
  end
end
