require 'spec_helper'

describe PunchTime do

	describe '#initialize' do
		context "when a valid timezone is entered" do
			it 'should return itself' do
				t = PunchTime.new 'America/New_York'

				expect(t).to eql(t)
			end
		end

		context "when an invalid timezone is entered" do
			it 'should raise an exception' do
				expect{PunchTime.new 'America/New York'}.to raise_error(TZInfo::InvalidTimezoneIdentifier)
			end
		end

		context "when no timezone is entered" do
			it 'should raise an exception' do
				expect{PunchTime.new}.to raise_error(ArgumentError)
			end
		end
	end

	describe '#now' do
		let(:punch_time) { PunchTime.new 'America/New_York' }

		it 'should return itself' do
			expect(punch_time.now).to eql(punch_time)
		end

		it 'should change the current time' do
			t = punch_time.set_time "01/01/00 00:00"

			expect( t.to_display ).to eq("01/01/2000 00:00")

			t.now

			expect( t.to_display ).not_to eq("01/01/2000 00:00")
		end
	end

	describe '#set_time' do
		let(:punch_time) { PunchTime.new 'America/New_York' }

		context 'when the same time is set twice' do
			it 'should be the same' do
				t = punch_time.set_time("01/01/2000 00:00")

				expect( t ).to eql( t.set_time("01/01/2000 00:00") )
			end
		end

		context 'when the time is set once' do
			it 'should be different' do
				t = punch_time

				expect( t.to_display ).not_to eq( punch_time.set_time("01/01/2000 00:00").to_display )
			end
		end
	end

	describe '#valid?' do
		let(:punch_time) { PunchTime.new 'America/New_York' }

		context 'when no time has been set' do
			it 'should not be valid' do
				expect( punch_time.valid? ).to be_false
			end
		end

		context 'when a time has been set' do
			it 'should be valid' do
				expect( punch_time.set_time('01/01/2000 00:00').valid? ).to be_true
			end
		end
	end

	describe '#to_db' do
		context 'when UTC is the timezone' do
			let(:punch_time) { PunchTime.new 'UTC' }
			it 'should return the same time that was entered' do
				expect( punch_time.set_time('01/01/2000 00:00').to_db.strftime("%m/%d/%Y %H:%M") ).to eq('01/01/2000 00:00')
			end
			it 'should return UTC time' do
				expect( punch_time.set_time('01/01/2000 00:00').to_db.zone ).to eq('UTC')
			end
		end

		context 'when UTC is not the timezone' do
			let(:punch_time) { PunchTime.new 'America/New_York' }
			it 'should return a different time than was entered' do
				expect( punch_time.set_time('01/01/2000 00:00').to_db.strftime("%m/%d/%Y %H:%M") ).not_to eq('01/01/2000 00:00')
			end

			it 'should return UTC time' do
				expect( punch_time.set_time('01/01/2000 00:00').to_db.zone ).to eq('UTC')
			end
		end
	end

end