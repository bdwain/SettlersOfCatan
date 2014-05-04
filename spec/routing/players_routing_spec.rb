require "spec_helper"

describe PlayersController do
  describe "routing" do

    it "routes to #create" do
      expect(post("/games/1/players")).to route_to("players#create", :game_id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/players/1")).to route_to("players#destroy", :id => "1")
    end

  end
end
