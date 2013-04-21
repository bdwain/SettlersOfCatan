require 'spec_helper'

describe Player do
  describe "game" do
    it { should belong_to(:game) }
    it { should validate_presence_of(:game_id) }
  end

  describe "user" do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user_id) }
  end

  describe "resources" do
    it { should have_many(:resources) }
  end

  describe "development_cards" do
    it { should have_many(:development_cards) }
  end

  describe "settlements" do
    it { should have_many(:settlements) }
  end

  describe "roads" do
    it { should have_many(:roads) }
  end

  describe "color" do
    it { should validate_presence_of(:color) }
    it { should validate_numericality_of(:color).only_integer }
  end

  describe "turn_num" do
    it { should validate_presence_of(:turn_num) }
    it { should validate_numericality_of(:turn_num).only_integer }
    it { should ensure_inclusion_of(:turn_num).in_range(3..4) } 
  end

  describe "turn_status" do
    it { should_not validate_presence_of(:turn_status) }
    it { should validate_numericality_of(:turn_status).only_integer }
  end
end
