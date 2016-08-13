require 'spec_helper'

describe Ruby::Utils::Param do
  let(:hash) do
    {
      a: 1,
      b: 2,
      c: {
        d: 3,
        e: {
          f: [{ff: 1},{ff: 3}
          ]
        }
      },
      w: 'some value'
    }
  end
  subject { Ruby::Utils::Param.new(hash) }

  describe '.mew' do
    it 'provides access to keys as methods' do
      expect(subject.a).to eq 1
      expect(subject.b).to eq 2
      expect(subject.c).to eq({
        d: 3,
        e: {
          f:[{ ff:1 }, { ff: 3 }
          ]
        }
      })
      expect(subject.c.d).to eq 3
      expect(subject.c.e).to eq({
        f: [{ff: 1}, {ff: 3}]
      })
    end

    it 'raised an error when requesting a method that is not a key' do
      expect{subject.non_existing}.to raise_error(NoMethodError)
    end
  end

  describe "#get" do
    it 'returns the values from string dot delimited keys' do
      expect(subject.get('a')).to eq(1)
      expect(subject.get('.a')).to eq(1)
      expect(subject.get('b')).to eq(2)
      expect(subject.get('.b')).to eq(2)
      expect(subject.get('c')).to eq(hash[:c])
      expect(subject.get('.c')).to eq(hash[:c])
      expect(subject.get('c.d')).to eq(3)
      expect(subject.get('c.e')).to eq(hash[:c][:e])
      expect(subject.get('.c.e')).to eq(hash[:c][:e])
      expect(subject.get('c.e.f')).to eq(hash[:c][:e][:f])
      expect(subject.get('.c.e.f')).to eq(hash[:c][:e][:f])
    end

    it 'raises an error whe ket is not present' do
      expect(true).to be true
      expect{subject.get('a.a.a.a')}.to raise_error(NoMethodError)
    end
  end

  describe '#getOrElse' do
    it 'returns the values from string dot delimited keys' do
      expect(subject.getOrElse('a')).to eq(1)
      expect(subject.getOrElse('.a')).to eq(1)
      expect(subject.getOrElse('b')).to eq(2)
      expect(subject.getOrElse('.b')).to eq(2)
      expect(subject.getOrElse('c')).to eq(hash[:c])
      expect(subject.getOrElse('.c')).to eq(hash[:c])
      expect(subject.getOrElse('c.d')).to eq(3)
      expect(subject.getOrElse('c.e')).to eq(hash[:c][:e])
      expect(subject.getOrElse('.c.e')).to eq(hash[:c][:e])
      expect(subject.getOrElse('c.e.f')).to eq(hash[:c][:e][:f])
      expect(subject.getOrElse('.c.e.f')).to eq(hash[:c][:e][:f])
    end

    context "when the key specified is not present in the hash" do
      it 'returns nil if no default value is given' do
        expect(subject.getOrElse('som.non.existing.key')).to eq nil
      end
      it 'returns the default value if one is given' do
        default = double('SomeDefaultValue')
        expect(subject.getOrElse('som.non.existing.key', default)).to eq default
      end
    end
  end

  [:to_hash, :to_h, :as_hash].each do |name|
    describe "#{name}" do
      it 'should return the original hash' do
        expect(subject.send(name)).to eq(hash)
      end
    end
  end


  describe '#defined?' do
    it 'returns true if key is present' do
      expect(subject.defined?('c.e.f')).to be true
      expect(subject.defined?('c.e')).to be true
      expect(subject.defined?('c')).to be true
    end
    it 'returns false if key is not present' do
      expect(subject.defined?('c.non_existing_key')).to be false
    end
  end

  describe '#all?' do
    it 'returns true whe all locators are present' do
      expect(subject.all?('a', 'b', 'c', 'c.e')).to be true
    end
    it 'returns fasle if at least one locator is not present' do
      expect(subject.all?('a', 'b', 'c', 'c.non_existing')).to be false
    end
    it 'returns false when no locator is present' do
      expect(subject.all?('_non_existing__')).to be false
    end
  end

  describe '#with' do
    context 'when a ket can be found' do
      it 'calls the block specified' do
        executed = false
        subject.with('c.e.f') { |cef_result|
          executed = true
          expect(cef_result).to eq subject.get('c.e.f')
        }

        expect(executed).to be true
      end
    end
    context 'when a key can not be found' do
      it 'should not call the block' do
        executed = false
        subject.with('__non_existing_key__') do |some_return_value|
          raise 'This block should not be called'
        end

        expect(executed).to be false
      end
    end
  end

  describe '#map' do
    context "when a key can be found" do
      it 'calls the given block to each value of the hash[key]' do
        expect(subject.a).to eq 1
        expect(subject.w).to eq 'some value'

        expect(subject.map('a', &:to_s)).to eq '1'
        expect(subject.map('w', &:upcase)).to eq 'SOME VALUE'
      end
    end
    context "when no key can be found" do
      it 'does not run the block given' do
        executed = false
        subject.map('__non_existing_key__') {
          raise 'THis block should not be called'
          executed = true
        }

        expect(executed).to be false
      end
    end
  end
end
