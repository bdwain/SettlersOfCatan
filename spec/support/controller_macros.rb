module ControllerMacros
  def login
    before(:each) do
      @current_user = FactoryGirl.create(:user)
      @current_user.confirm!
      sign_in @current_user
    end
  end
end