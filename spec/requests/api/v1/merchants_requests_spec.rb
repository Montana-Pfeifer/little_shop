require 'rails_helper'

RSpec.describe "Merchants endpoints", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Test Merchant 1", created_at: 3.seconds.ago)
    @merchant_2 = Merchant.create!(name: "Test Merchant 2", created_at: 2.seconds.ago)
    @merchant_3 = Merchant.create!(name: "Test Merchant 3", created_at: 1.seconds.ago)

    @item_1 = Item.create!(name: "Item 1", description: "Description 1", unit_price: 10.0, merchant: @merchant_1)
    @item_2 = Item.create!(name: "Item 2", description: "Description 2", unit_price: 15.0, merchant: @merchant_1)
    @item_3 = Item.create!(name: "Item 3", description: "Description 3", unit_price: 20.0, merchant: @merchant_2)
  end

  it "can retrieve ALL merchants" do
    get "/api/v1/merchants"
    
    expect(response.status).to eq(200)
    
    merchants = JSON.parse(response.body, symbolize_names: true)[:data]
    
    expect(response).to be_successful
    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to be_a(String)

      expect(merchant).to have_key(:attributes)
      attributes = merchant[:attributes]
      
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)
    end
  end

  it "can destroy merchant" do
    merchants = Merchant.all
    expect(merchants.count).to eq(3)
    
    delete "/api/v1/merchants/#{@merchant_2.id}"

    expect(response).to be_successful 
    expect(response.status).to eq(204)

    expect(merchants.count).to eq(2)
  end
  
  it "can create new merchants" do 
    attributes = {
      name: "the chocolate bar guy",
    }

    post "/api/v1/merchants", params:{merchant: attributes}

    merchant_new = JSON.parse(response.body, symbolize_names: true)

    id = merchant_new[:data]

    get "/api/v1/merchants"

    all_merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(merchant_new[:data][:attributes][:name]).to eq("the chocolate bar guy")
    expect(all_merchants[:data]).to include(id)
  end
  
  it "can retrieve a single merchant by id" do
    id = @merchant_1.id
    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)
   
    expect(response.status).to eq(200)
    expect(merchant).to have_key(:data)

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to be_a(String)

    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to be_a(String)

    expect(merchant[:data]).to have_key(:attributes)
    attributes = merchant[:data][:attributes]

    expect(attributes).to have_key(:name)
    expect(attributes[:name]).to be_a(String)
  end

  it "returns merchants sorted by creation date (newest first)" do
    get "/api/v1/merchants?sorted=age"

    merchants = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(response).to be_successful

    expect(merchants[0][:attributes][:name]).to eq("Test Merchant 3")
    expect(merchants[1][:attributes][:name]).to eq("Test Merchant 2")
    expect(merchants[2][:attributes][:name]).to eq("Test Merchant 1")
  end

  it "can update a merchant by id" do
    previous_name = @merchant_1.name
    merchant_params = { name: "Billy" }
    headers = { "CONTENT_TYPE" => "application/json" }

    patch "/api/v1/merchants/#{@merchant_1.id}", headers: headers, params: JSON.generate({ merchant: merchant_params })
    
    changed_merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(changed_merchant[:data][:attributes][:name]).to_not eq(previous_name)
    expect(changed_merchant[:data][:attributes][:name]).to eq("Billy")
  end

  it "includes the correct item_count in the response when count=true" do
    get "/api/v1/merchants?count=true"
  
    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)[:data]

    merchant_1_data = merchants.find { |merchant| merchant[:id] == @merchant_1.id.to_s }
    merchant_2_data = merchants.find { |merchant| merchant[:id] == @merchant_2.id.to_s }
    merchant_3_data = merchants.find { |merchant| merchant[:id] == @merchant_3.id.to_s }

    expect(merchant_1_data[:attributes][:item_count]).to eq(2) 
    expect(merchant_2_data[:attributes][:item_count]).to eq(1)
    expect(merchant_3_data[:attributes][:item_count]).to eq(0) 
  end

  it "returns only merchants that have invoices with status 'returned'" do
    customer = Customer.create!(first_name: "Gordon", last_name: "Ramsey")

    merchant_with_returned_invoice = Merchant.create!(name: "Merchant With Returned Invoice")
    merchant_without_returned_invoice = Merchant.create!(name: "Merchant Without Returned Invoice")
    another_merchant_with_returned_invoice = Merchant.create!(name: "Another Merchant With Returned Invoice")

    Invoice.create!(merchant: merchant_with_returned_invoice, customer: customer, status: "returned")
    Invoice.create!(merchant: merchant_without_returned_invoice, customer: customer, status: "shipped")
    Invoice.create!(merchant: another_merchant_with_returned_invoice, customer: customer, status: "returned")
    Invoice.create!(merchant: merchant_without_returned_invoice, customer: customer, status: "completed")

    get "/api/v1/merchants?status=returned"

    expect(response).to be_successful
    merchants = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(merchants.count).to eq(2)
      
    returned_merchant_names = merchants.map { |merchant| merchant[:attributes][:name] }
    expect(returned_merchant_names).to contain_exactly("Merchant With Returned Invoice", "Another Merchant With Returned Invoice")
  end

  describe "GET /api/v1/merchants/:id" do
    it "returns a 404 error when the merchant does not exist" do
      get "/api/v1/merchants/9999" 

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:errors][0][:status]).to eq("404")
      expect(json_response[:errors][0][:title]).to eq("Couldn't find Merchant with 'id'=9999")
    end

    it "returns a 404 error when searching with a string" do
      get "/api/v1/merchants/merchant-name" 

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:errors][0][:status]).to eq("404")
      expect(json_response[:errors][0][:title]).to eq("Couldn't find Merchant with 'id'=merchant-name")
    end
  end
  
  describe "PATCH /api/v1/merchants/:id" do
    it "returns a 404 error when the merchant does not exist" do
      patch "/api/v1/merchants/9999", params: { merchant: { name: "Mrs. Potato Head" } }

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:errors][0][:status]).to eq("404")
      expect(json_response[:errors][0][:title]).to eq("Couldn't find Merchant with 'id'=9999")
    end
  end

  describe "DELETE /api/v1/merchants/:id" do
    it "returns a 404 error when a merchant does not exist to delete" do
      delete "/api/v1/merchants/9999" 

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:errors][0][:status]).to eq("404")
      expect(json_response[:errors][0][:title]).to eq("Couldn't find Merchant with 'id'=9999")
    end

    it "returns a 404 if the id is incorrect format" do
      delete "/api/v1/merchants/mymerchant" 

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:errors][0][:status]).to eq("404")
      expect(json_response[:errors][0][:title]).to eq("Couldn't find Merchant with 'id'=mymerchant")
    end
  end

  describe "find one MERCHANT based on search criteria" do
    it 'returns one merchant based on name criteria' do
          @merchant_4 = Merchant.create!(name: "a Test Merchant 4", created_at: 1.seconds.ago) 
      get "/api/v1/merchants/find?name=tEst"

      found_merchant = JSON.parse(response.body, symbolize_names: true)
 
      expect(response).to be_successful
      expect(found_merchant.count).to eq(1)
      expect(found_merchant).to be_an(Hash)
      expect(found_merchant[:data][:attributes][:name]).to eq("a Test Merchant 4")
    end

    it 'returns an empty array if there are no matches' do
       get "/api/v1/merchants/find?name=xxxxxxx"

       merchant = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      
      expect(merchant).to be_an(Hash)
      expect(merchant[:data]).to eq({})
      expect(merchant).to eq({:data=>{}})
    end

    it 'returns an error when name is not provided' do
      get "/api/v1/merchants/find?name="

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(merchant[:errors][0][:status]).to eq("400")
    end
  end

  describe "POST /api/v1/merchants", type: :request do
    it "returns a 400 error with bad request response" do

      post "/api/v1/merchants", params: {}
  
      expect(response).to have_http_status(:bad_request)
  
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:message]).to eq("your query could not be completed")
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:errors][0][:status]).to eq("400")
      expect(json_response[:errors][0][:title]).to include("param is missing")
    end
  end 

  describe "POST /api/v1/merchants with invalid JSON", type: :request do
    it "returns a 400 error for invalid JSON format" do
      post "/api/v1/merchants", params: "{ invalid json", headers: { "CONTENT_TYPE" => "application/json" }
  
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors][0][:title]).to eq("Invalid JSON format")
    end
  end

  describe "cant create merchants with incorrect or invalid input" do
    it "cant create a merchant with no name entered" do
      attributes = {
      }
    
      post "/api/v1/merchants", params:{merchant: attributes}
      
      expect(response).to_not have_http_status(200)
    end
  end

  describe "can't delete merchant twice" do
    it "can not delete same merchant twice" do

    delete "/api/v1/merchants/#{@merchant_1.id}"
    delete "/api/v1/merchants/#{@merchant_1.id}"

    expect(response).to have_http_status(:not_found) 
    end
  end
end

