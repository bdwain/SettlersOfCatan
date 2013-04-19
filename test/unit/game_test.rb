require 'test_helper'

class GameTest < ActiveSupport::TestCase
   test "missing gamestatus" do
      game = games(:valid_test_game)
      assert game.valid?
   end
end
