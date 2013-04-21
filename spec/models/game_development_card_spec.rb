require 'spec_helper'

describe GameDevelopmentCard do
  describe "card_position" do
    it { should_not validate_presence_of(:card_position) }
    it { should validate_numericality_of(:card_position).only_integer }
    it { should_not allow_value(-1).for(:card_position) }
    it { should allow_value(0).for(:card_position) }
  end

  describe "card_type" do
    it { should validate_presence_of(:card_type) }
    it { should validate_numericality_of(:card_type).only_integer }
  end
end
