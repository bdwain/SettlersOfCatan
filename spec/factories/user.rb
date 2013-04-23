FactoryGirl.define do
  sequence(:displayname) {|n| "person#{n}" }
  sequence(:email) {|n| "person#{n}@example.com" }
  
  factory :user do
    displayname
    email
    password "password"
    password_confirmation {"#{password}"}

    factory :confirmed_user do
      after(:create) { |user| user.confirm!}
    end
  end  
end