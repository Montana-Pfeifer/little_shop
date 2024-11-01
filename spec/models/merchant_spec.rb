require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'Associations' do
    it { should have_many(:items) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
  end

  describe '.fetch_merchants' do
    before(:each) do
      @merchant_1 = Merchant.create!(name: "Test Merchant 1", created_at: 3.seconds.ago)
      @merchant_2 = Merchant.create!(name: "Test Merchant 1", created_at: 2.seconds.ago)
      @merchant_3 = Merchant.create!(name: "Test Merchant 3", created_at: 1.second.ago)

      @item_1 = Item.create!(name: "Item 1", description: "Description 1", unit_price: 10.0, merchant: @merchant_1)
      @item_2 = Item.create!(name: "Item 2", description: "Description 2", unit_price: 15.0, merchant: @merchant_1)
      @item_3 = Item.create!(name: "Item 3", description: "Description 3", unit_price: 20.0, merchant: @merchant_2)
    end

    it "returns all merchants when no sorted parameter is provided" do
      result = Merchant.fetch_merchants({})

      expect(result.count).to eq(3)
      expect(result).to contain_exactly(@merchant_1, @merchant_2, @merchant_3)
    end

    it "returns merchants sorted by created_at timestamp, newest first, when sorted=age is provided" do
      result = Merchant.fetch_merchants({ sorted: 'age' })

      expect(result.count).to eq(3)
      expect(result.first).to eq(@merchant_3) 
      expect(result.last).to eq(@merchant_1)  
    end

    it "returns merchants with item_count when count=true is provided" do
      result = Merchant.fetch_merchants({ count: 'true' })
    
      expect(result.count).to eq(3)
    
      expect(result[0].item_count).to eq(2) 
      expect(result[1].item_count).to eq(1) 
      expect(result[2].item_count).to eq(0) 
    end

    it "returns the correct item count for each merchant" do
      expect(@merchant_1.item_count).to eq(2) 
      expect(@merchant_2.item_count).to eq(1) 
      expect(@merchant_3.item_count).to eq(0) 
    end
    
    it "returns only merchants that have invoices with status 'returned' when ?status=returned is provided" do

      customer = Customer.create!(first_name: "John", last_name: "Doe")
      
      merchant_with_returned_invoice = Merchant.create!(name: "Merchant With Returned Invoice")
      merchant_without_returned_invoice = Merchant.create!(name: "Merchant Without Returned Invoice")
      another_merchant_with_returned_invoice = Merchant.create!(name: "Another Merchant With Returned Invoice")

      Invoice.create!(merchant: merchant_with_returned_invoice, customer: customer, status: "returned")
      Invoice.create!(merchant: merchant_without_returned_invoice, customer: customer, status: "shipped")
      Invoice.create!(merchant: another_merchant_with_returned_invoice, customer: customer, status: "returned")
      Invoice.create!(merchant: merchant_without_returned_invoice, customer: customer, status: "completed")

      result = Merchant.fetch_merchants({ status: 'returned' })

      expect(result.count).to eq(2)
      expect(result).to contain_exactly(merchant_with_returned_invoice, another_merchant_with_returned_invoice)
    end
  end
end