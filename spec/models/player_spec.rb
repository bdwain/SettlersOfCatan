require 'spec_helper'

describe Player do
  describe "game" do
    it { should belong_to(:game) }
    it { should validate_presence_of(:game) }
  end

  describe "user" do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user) }
    it "validates_uniqueness_of user_id scoped to game_id" do
      #needed because the validation fails without a player precreted. See docs.
      FactoryGirl.create(:player)
      should validate_uniqueness_of(:user_id).scoped_to(:game_id)
     end 
  end

  describe "resources" do
    it { should have_many(:resources).dependent(:destroy) }
  end

  describe "development_cards" do
    it { should have_many(:development_cards).dependent(:destroy) }
  end

  describe "settlements" do
    it { should have_many(:settlements).dependent(:destroy) }
  end

  describe "roads" do
    it { should have_many(:roads).dependent(:destroy) }
  end

  describe "turn_num" do
    it { should validate_presence_of(:turn_num) }
    it { should validate_numericality_of(:turn_num).only_integer }
    it { should ensure_inclusion_of(:turn_num).in_range(1..4) } 
  end

  describe "turn_status" do
    it { should_not validate_presence_of(:turn_status) }
    it { should validate_numericality_of(:turn_status).only_integer }
  end
end
