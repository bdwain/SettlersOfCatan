require 'spec_helper'

describe GameLog do
  describe "current_player" do
    it { should belong_to(:current_player).class_name(:Player) }
    it { should validate_presence_of(:current_player) }
  end

  describe "recipient" do
    it { should belong_to(:recipient).class_name(:Player) }
  end

  describe "turn_num" do
    it { should validate_presence_of(:turn_num) }
    it { should validate_numericality_of(:turn_num).only_integer }
    it { should_not allow_value(0).for(:turn_num) }
    it { should allow_value(1).for(:turn_num) }
  end

  describe "msg" do
    it { should validate_presence_of(:msg) }
  end
end
