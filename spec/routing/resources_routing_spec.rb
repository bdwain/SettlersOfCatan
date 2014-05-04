require "spec_helper"

describe ResourcesController do
  describe "routing" do

    it "routes to #update" do
      expect(patch("/players/1/resources")).to route_to("resources#update", :player_id => "1")
    end
  end
end
