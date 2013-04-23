FactoryGirl.define do
  factory :player do
    #repeat sequences from 1 to 4 to always have a valid number
    sequence(:color, 0) {|n| (n % 4) + 1} 
    sequence(:turn_num, 0) {|n| (n % 4) + 1}
    game
    association :user, factory: :confirmed_user
  end  
end