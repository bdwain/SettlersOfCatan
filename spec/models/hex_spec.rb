require 'spec_helper'

describe Hex do
  describe "map" do
    it { should belong_to(:map) }
    it { should validate_presence_of(:map) }
  end

  describe "dice_num" do
    it { should ensure_inclusion_of(:dice_num).in_range(2..12).allow_nil(true) } 
  end

  describe "resource_type" do
    it { should validate_presence_of(:resource_type) }
    it { should validate_numericality_of(:resource_type).only_integer }
  end

  describe "pos_x" do
    it { should validate_presence_of(:pos_x) }
    it { should validate_numericality_of(:pos_x).only_integer }
    it { should_not allow_value(-1).for(:pos_x) }
    it { should allow_value(0).for(:pos_x) }
  end

  describe "pos_y" do
    it { should validate_presence_of(:pos_y) }
    it { should validate_numericality_of(:pos_y).only_integer }
    it { should_not allow_value(-1).for(:pos_y) }
    it { should allow_value(0).for(:pos_y) }
  end
end
