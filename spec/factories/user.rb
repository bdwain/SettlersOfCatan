FactoryGirl.define do
  sequence(:displayname) {|n| "pl#{n}" }
  sequence(:email) {|n| "p#{n}@foo.com" }
  
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