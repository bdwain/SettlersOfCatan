require 'spec_helper'

describe DiceRoll do
  describe "current_player" do
    it { should belong_to(:current_player).class_name(:Player) }
    it { should validate_presence_of(:current_player) }
  end

  describe "turn_num" do
    it { should validate_presence_of(:turn_num) }
    it { should validate_numericality_of(:turn_num).only_integer }
    it { should_not allow_value(0).for(:turn_num) }
    it { should allow_value(1).for(:turn_num) }
  end

  describe "die_1" do
    it { should validate_presence_of(:die_1) }
    it { should ensure_inclusion_of(:die_1).in_range(1..6) } 
  end

  describe "die_2" do
    it { should validate_presence_of(:die_2) }
    it { should ensure_inclusion_of(:die_2).in_range(1..6) } 
  end  
end
