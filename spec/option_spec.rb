require 'spec_helper'

module Ruby::Utils
  describe Option do
    describe 'None' do
      subject { None.instance }

      it { expect(subject).to be_empty }
      it { expect{subject.get}.
           to raise_error(Ruby::Utils::None::NoSuchElementError)
      }

      it { expect(subject.defined?).to be false }

      context '#get_or_else' do
        it 'returns the default value' do
          default = double("SomeValue")
          expect(subject.get_or_else(default)).to eq default
        end
      end

      context '#map' do
        it { expect(subject.map(->(){})).to eq subject }
        it 'calls the block if one is given' do
          expect(subject.map{ |v| v * 100 }).to eq subject
        end
      end

      context '#flat_map' do
        it { expect(subject.flat_map(->{})).to eq subject }
      end

      context '#filter' do
        it { expect(subject.filter(->(x){ x == 1 })).to eq subject }
      end

      context '#for_each' do
        it { expect(subject.for_each(->{})).to eq nil }
      end
      context '#or_else' do
        let(:other) { double("OtherObject") }
        it { expect(subject.or_else(other)).to eq other }
      end
      context '#to_a' do
        it { expect(subject.to_a).to eq Array.new }
      end
    end

    describe 'Some' do
      let(:value) { Class.new }
      subject { Some.new(value) }

      it { expect(subject).to_not be_empty }
      it { expect(subject).to be_defined }
      it { expect(subject.get).to eq value }

      context '#get_or_else' do
        it { expect(subject.get_or_else("other")).to eq value }
      end
      context '#map' do
        subject { Some.new(100) }
        it 'maps applies the lambda to the value' do
          f = ->(x) { x * 100 }
          result = subject.map(f)
          expect(result).to eq Some.new(10000)
        end

        it 'calls the block if one is given' do
          result = subject.map { |v| v * 2 }
          expect(result.get).to eq 200
        end
      end

      context '#flat_map' do
        subject { Some.new(10) }
        it 'calls a proc if one is provided as argument' do
          f = ->(x) { x * x }
          result = subject.flat_map(f)
          expect(result).to eq 100
        end

        it 'calls the block if one is provided' do
          result = subject.flat_map { |val| val * 3 }
          expect(result).to eq 30
        end
      end

      context '#filter' do
        subject { Some.new('ruby') }
        context 'when a block is given' do
          it 'returns none when block evals to false' do
            res = subject.filter{|val|
              val == 'some'
            }
            expect(res).to eq None.instance
          end
          it 'returns self whne the block evals to true' do
            res = subject.filter {|val|
              val == 'ruby'
            }

            expect(res).to eq subject
          end
        end
        context 'when a proc alrgument is provided' do
          it 'returns self when predicate is applied to value and returns true' do
            f = ->(s){ s == 'ruby' }
            result = subject.filter(f)
            expect(result).to eq subject
          end
          it 'returns a None instance when predicate evals to false' do
            f = ->(s) { s == 'asasas' }
            result = subject.filter(f)
            expect(result).to eq None.instance
          end
        end
      end

      context '#for_each' do
        subject { Some.new('rabbit') }
        it 'calls the proc if one is provided' do
          f = -> (s) { s.upcase }
          expect(subject.for_each(f)).to eq 'RABBIT'
        end

        it 'calls the block if one is given' do
          res = subject.for_each { |v| v.upcase }
          expect(res).to eq 'RABBIT'
        end
      end

      context '#or_else' do
        subject { Some.new(100) }
        it { expect(subject.or_else(121212)).to eq subject }
      end

      context '#to_a' do
        subject { Some.new(100) }
        it { expect(subject.to_a).to eq Array(subject.get) }
      end
    end
  end
end
