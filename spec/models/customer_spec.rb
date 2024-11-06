require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe "Associations" do
    it { should have_many :invoices }
  end

  describe 'Validations' do 
    it {should validate_presence_of(:first_name) }
    it {should validate_presence_of(:last_name) }
  end

  describe "test the custmomers for merchant" do
    it "can return customers information for a givin merchant" do 
      merchant1 = Merchant.create(name: "Test Merchant 1", created_at: 3.seconds.ago)
      merchant2 = Merchant.create(name: "Test Merchant 2", created_at: 2.seconds.ago)
      merchant3 = Merchant.create(name: "Test Merchant 3", created_at: 1.second.ago)

      customer_1 = Customer.create(first_name: "Abby", last_name: "Bronson")
      customer_2 = Customer.create(first_name: "Catherine", last_name: "Deitch")
      customer_3 = Customer.create(first_name: "Edgar", last_name: "Flores")
      customer_4 = Customer.create(first_name: "Gordan", last_name: "Herrowits")

      invoice_1 = Invoice.create(customer_id: (customer_1[:id]) , merchant_id: (merchant1[:id]), status: "returned")
      invoice_2 = Invoice.create(customer_id: (customer_3[:id]) , merchant_id: (merchant2[:id]), status: "returned")
      invoice_3 = Invoice.create(customer_id: (customer_4[:id]) , merchant_id: (merchant3[:id]), status: "returned")
      invoice_4 = Invoice.create(customer_id: (customer_1[:id]) , merchant_id: (merchant1[:id]), status: "returned")
      invoice_4 = Invoice.create(customer_id: (customer_1[:id]) , merchant_id: (merchant2[:id]), status: "returned")

      customer1 = (Customer.show_all_customers((merchant1.id)))
      customer31 = (Customer.show_all_customers((merchant2.id)))

      expect(customer1).to contain_exactly(customer_1)
      expect(customer31).to contain_exactly(customer_1, customer_3)
    end
  end
end