require "spec_helper"

describe DiceRollsController do
  describe "routing" do

    it "routes to #create" do
      expect(post("/players/1/dice_rolls")).to route_to("dice_rolls#create", :player_id => "1")
    end
  end
end
