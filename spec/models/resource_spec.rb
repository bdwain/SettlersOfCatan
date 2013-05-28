require 'spec_helper'

describe Resource do
  describe "player" do
    it { should belong_to(:player) }
    it { should validate_presence_of(:player) }
  end

  describe "type" do
    it { should validate_presence_of(:type) }
    it { should validate_numericality_of(:type).only_integer }
    it "validates_uniqueness_of type scoped to player_id" do
      #needed because the validation fails without a resource precreted. See docs.
      FactoryGirl.create(:resource)
      should validate_uniqueness_of(:type).scoped_to(:player_id)
    end    
  end

  describe "count" do
    it { should validate_presence_of(:count) }
    it { should validate_numericality_of(:count).only_integer }
    it { should_not allow_value(-1).for(:count) }
    it { should allow_value(0).for(:count) }    
  end
end
