require 'spec_helper'

describe DevelopmentCard do
  describe "game" do
    it { should belong_to(:game) }
    it { should validate_presence_of(:game_id) }
  end
    
  describe "card_position" do
    it { should_not validate_presence_of(:position) }
    it { should validate_numericality_of(:position).only_integer }
    it { should_not allow_value(-1).for(:position) }
    it { should allow_value(0).for(:position) }
  end

  describe "card_type" do
    it { should validate_presence_of(:type) }
    it { should validate_numericality_of(:type).only_integer }
  end
end
