require 'test_helper'

class UserTest < ActiveSupport::TestCase
   test "missing displayname" do
      user = users(:testuser)
      user.displayname = nil
      assert user.invalid?
   end
   test "too short displayname" do
      user = users(:testuser)
      user.displayname = "aa"
      assert user.invalid?
   end
   test "good minlength displayname" do
      user = users(:testuser)
      user.displayname = "aaa"
      assert user.valid?
   end
   test "good maxlength displayname" do
      user = users(:testuser)
      user.displayname = "a"*20
      assert user.valid?
   end
   test "too long displayname" do
      user = users(:testuser)
      user.displayname = "a"*21
      assert user.invalid?
   end
end
