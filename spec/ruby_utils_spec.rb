require 'spec_helper'

describe Ruby::Utils do
  describe 'Param' do
    it 'returns a new param instance' do
      instance = Ruby::Utils::Param({ a: 1 })
      expect(instance).to be_a Ruby::Utils::Param
    end
  end

  describe 'None' do
    it 'returns a None instance' do
      none = None
      expect(none).to eq Ruby::Utils::None.instance
    end
  end

  describe '#Some' do
    let(:value) { double('SomeDouble') }
    subject { Some(value) }

    it 'should return a Some instance' do
      expect(subject).to be_a Ruby::Utils::Some
      expect(subject.get).to eq value
    end
  end

  context 'Pseudo pattern matching' do
    it 'returns the value on Some instance' do
      some = Some("lp")

      result = some.match {
        on Some(name) => name
        on None => "missing data"
      }

      expect(result).to eq 'lp'
    end

    it 'returns None on None object' do
      none = None
      result = none.match{
        on Some(x) => x
        on None => "Missing value"
      }

      expect(result).to eq "Missing value"
    end

    it 'can manipulate the value on some' do
      some = Some(10)

      result = some.match{
        on Some(x) => x * 2
        on None => 'missing'
      }

      expect(result).to eq 20

      some = Some "ruby"
      result = some.match {
        on Some(s) => s.upcase
      }

      expect(result).to eq 'RUBY'
    end

    it 'does not manipulate the value on None' do
      none = None

      result = none.match {
        on Some(x) => x * 100
        on None => 0
      }

      expect(result).to eq 0
    end

    it 'evals Some when defined last' do
      some = Some(12)
      result = some.match{
        on None => 0
        on Some(x) => x * 2
      }

      expect(result).to eq 24
    end

    it 'evals None when defined first' do
      none = None
      result = none.match{
        on Some(x) => x * x
        on None => 'missing'
      }

      expect(result).to eq 'missing'
    end
  end
end
