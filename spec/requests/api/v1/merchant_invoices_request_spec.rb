require 'rails_helper'

RSpec.describe"merchant invoices endpoints:", type: :request do
    before(:each) do
      @merchant_1 = Merchant.create!(name: "Test Merchant 1", created_at: 3.seconds.ago)
      @merchant_2 = Merchant.create!(name: "Test Merchant 2", created_at: 2.seconds.ago)
      @customer_1 = Customer.create!(first_name: 'josef', last_name: "booker")
    
      @invoice_1 = Invoice.create!(customer_id: (@customer_1.id), merchant_id: @merchant_1.id, status: "shipped")
      @invoice_2 = Invoice.create!(customer_id: (@customer_1.id), merchant_id: @merchant_1.id, status: "packaged")
      @invoice_3 = Invoice.create!(customer_id: (@customer_1.id), merchant_id: @merchant_1.id, status: "returned")
    end

    it 'can get all invoices' do
        get "/api/v1/merchants/#{@merchant_1.id}/invoices"

        expect(response.status).to eq(200)

    invoices = JSON.parse(response.body, symbolize_names: true)
        expect(invoices[:data].length).to eq(3)

        get "/api/v1/merchants/#{@merchant_2.id}/invoices"

        expect(response.status).to eq(200)
        invoices = JSON.parse(response.body, symbolize_names: true)
        expect(invoices[:data].length).to eq(0)
    end

    it 'can get all invoices of a status' do
        get "/api/v1/merchants/#{@merchant_1.id}/invoices?status=shipped"
        expect(response.status).to eq(200)

        invoices = JSON.parse(response.body, symbolize_names: true)
        expect(invoices[:data].length).to eq(1)
    end
end