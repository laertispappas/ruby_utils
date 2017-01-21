require 'spec_helper'

module Ruby::Utils
  describe List do
    context 'match' do
      it 'matches on Cons' do
        subject = List[1,2,3]
        result = subject.match {
          kase Nil => 0
          kase [x, xs] => x * 2
        }

        expect(result).to eq 2
      end

      it 'matches on Nil' do
        subject = List[]
        expect(subject).to be_a Nil
        result = subject.match {
          kase Nil => 0
          kase [a, b] => 'aaa'
        }

        expect(result).to eq 0
      end

      it 'test Nil last match' do
        subject = List[1,2,3]

        result = subject.match{
          kase [x, xs] => 1212
          kase Nil => 12
        }

        expect(result).to eq 1212
      end

      it 'test recursion' do
        subject = List[1,2,3]

        def sum(list)
          list.match{
            kase Nil => 0
            kase [x, xs] => x + sum(xs)
          }

          result = sum(subject)
          expect(result).to eq 6
        end
      end
    end
  end
end
