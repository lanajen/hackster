# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :part do
    quantity 1
    unit_price 1.5
    name "MyString"
    vendor_name "MyString"
    vendor_sku "MyString"
    vendor_link "MyString"
  end
end
