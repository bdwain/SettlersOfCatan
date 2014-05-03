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

  describe "name" do
    shared_examples "returns proper type string" do
      it "returns the proper type string" do
        expect(resource.name).to eq(type_str)
      end
    end

    context "when type is DESERT" do
      let(:resource) {FactoryGirl.build(:resource, {:type => DESERT})}
      let(:type_str) {"DESERT"}
      include_examples "returns proper type string"
    end

    context "when type is WOOD" do
      let(:resource) {FactoryGirl.build(:resource, {:type => WOOD})}
      let(:type_str) {"WOOD"}
      include_examples "returns proper type string"
    end

    context "when type is WHEAT" do
      let(:resource) {FactoryGirl.build(:resource, {:type => WHEAT})}
      let(:type_str) {"WHEAT"}
      include_examples "returns proper type string"
    end

    context "when type is WOOL" do
      let(:resource) {FactoryGirl.build(:resource, {:type => WOOL})}
      let(:type_str) {"WOOL"}
      include_examples "returns proper type string"
    end

    context "when type is ORE" do
      let(:resource) {FactoryGirl.build(:resource, {:type => ORE})}
      let(:type_str) {"ORE"}
      include_examples "returns proper type string"
    end

    context "when type is BRICK" do
      let(:resource) {FactoryGirl.build(:resource, {:type => BRICK})}
      let(:type_str) {"BRICK"}
      include_examples "returns proper type string"
    end

    context "when type is an undefined type" do
      let(:resource) {FactoryGirl.build(:resource, {:type => -1})}

      it "raises an exception" do
        expect{
          resource.name
        }.to raise_exception("Invalid resource type")
      end
    end
  end
end
