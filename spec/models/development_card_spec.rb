require 'spec_helper'

describe DevelopmentCard do
  describe "game" do
    it { should belong_to(:game) }
    it { should validate_presence_of(:game) }
  end

  describe "player" do
    it { should belong_to(:player) }
  end
    
  describe "position" do
    it { should_not validate_presence_of(:position) }
    it { should validate_numericality_of(:position).only_integer }
    it { should_not allow_value(-1).for(:position) }
    it { should allow_value(0).for(:position) }
  end

  describe "type" do
    it { should validate_presence_of(:type) }
    it { should validate_numericality_of(:type).only_integer }
  end

  describe "turn_bought" do
    it { should_not validate_presence_of(:turn_bought) }
    it { should validate_numericality_of(:turn_bought).only_integer }
    it { should_not allow_value(-1).for(:turn_bought) }
    it { should allow_value(0).for(:turn_bought) }
  end

  describe "turn_used" do
    it { should_not validate_presence_of(:turn_used) }
    it { should validate_numericality_of(:turn_used).only_integer }
    it { should_not allow_value(-1).for(:turn_used) }
    it { should allow_value(0).for(:turn_used) }
  end
end
