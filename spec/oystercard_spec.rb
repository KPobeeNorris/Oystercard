require 'oystercard'

describe Oystercard do
  subject(:oystercard) { Oystercard.new }
  let(:start_journey) { double :start_journey }
  let(:end_journey) { double :end_journey }
  let(:entry_station) { double :entry_station }
  let(:journey_history) { double :journey_history }
  let(:current_journey) { double(entry_station: nil, exit_station: nil) }

  it 'has a starting balance of 0' do
    oystercard.deduct(10)
    expect(oystercard.balance).to eq(0)
  end

  before :each do
    oystercard.top_up(10)
  end

  describe '#top_up' do
    it { is_expected.to respond_to(:top_up).with(1).argument }

    it 'tops up balance' do
      top_up_value = 10
      expect { oystercard.top_up(top_up_value) }
        .to change { oystercard.balance }.by top_up_value
    end

    it 'enforces maximum balance' do
      error = 'Maximum balance exceeded'
      top_up_value = 125
      expect { oystercard.top_up(top_up_value) }.to raise_error error
    end
  end

  describe '#deduct' do
    it { is_expected.to respond_to(:deduct).with(1).argument }

    it 'deducts balance' do
      deducted_value = Oystercard::MIN_CHARGE
      expect { oystercard.deduct(deducted_value) }
        .to change { oystercard.balance }.by(- deducted_value)
    end
  end

  describe '#touch_in' do
    it { is_expected. to respond_to(:touch_in) }
    it 'changes the status of the card when touching in' do
      expect(oystercard.touch_in(start_journey)).to be true
    end

    it 'checks minimum balance' do
      oystercard.deduct(10)
      error = 'Insuficient balance'
      expect { oystercard.touch_in(start_journey) }.to raise_error error
    end

    it 'record entry station' do
      oystercard.touch_in('southwark')
      expect(oystercard.current_journey[:entry_station]).to eq 'southwark'
    end
  end

  describe '#touch_out' do
    it { is_expected.to respond_to(:touch_out) }

    it 'changes the status of the card when touching out' do
      oystercard.touch_in(start_journey)
      expect(oystercard.touch_out(end_journey)).to be false
    end

    it 'deducts balance when touching out' do
      deducted_value = 1.5
      expect { oystercard.touch_out(end_journey) }
        .to change { oystercard.balance }.by(- deducted_value)
    end
  end

  describe '#in_journey?' do
    it { is_expected.to respond_to(:in_journey?) }
    it 'confirms that the customer is not on a journey' do
      expect(oystercard).not_to be_in_journey
    end
  end

  describe 'journey history' do
    it 'checks that journey history is empty when card is created' do
    expect(oystercard.journey_history).to eq []
  end

    it 'checks that touching in and out stores a journey' do
      oystercard.touch_in('southwark')
      oystercard.touch_out('aldgate')
      expect(oystercard.journey_history).to eq [{entry_station: 'southwark', exit_station: 'aldgate'}]
    end
end


end
