require 'rails_helper'

RSpec.describe "Item endpoints", type: :request do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Test Merchant 1", created_at: 3.seconds.ago)
    @merchant_2 = Merchant.create!(name: "Test Merchant 2", created_at: 2.seconds.ago)
    @merchant_3 = Merchant.create!(name: "Test Merchant 3", created_at: 1.seconds.ago)

    @item_1 = Item.create!(name: "Precision Scale", description: "Weighs", unit_price:100.91 , merchant: @merchant_1)
    @item_2 = Item.create!(name: "Digital Thermometer", description: "Reads temperature", unit_price:300.23 , merchant: @merchant_2)
    @item_3 = Item.create!(name: "Silicone Baking Mat", description: "Non-stick magic", unit_price:20.23 , merchant: @merchant_3)
  end

  it "can retrieve ALL items" do
    get "/api/v1/items"

    expect(response.status).to eq(200)
    
    items = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(items.count).to eq(3)

    items.each do |item|

      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:type)
      expect(item[:type]).to be_a(String)

      expect(item).to have_key(:attributes)
      attributes = item[:attributes]
      
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)

      expect(attributes).to have_key(:description)
      expect(attributes[:description]).to be_a(String)

      expect(attributes).to have_key(:unit_price)
      expect(attributes[:unit_price]).to be_a(Float)

      expect(attributes).to have_key(:merchant_id)
      expect(attributes[:merchant_id]).to be_a(Integer)
    end
  end

  it "can destroy items" do
    items = Item.all
    expect(items.count).to eq(3)
    
    delete "/api/v1/items/#{@item_2.id}"

    expect(response).to be_successful 
    expect(response.status).to eq(204)

    expect(items.count).to eq(2)
  end

  it "can create new items" do 
    attributes = {
      name: "chocolate bar",
      description: "sweet and delicious",
      unit_price: 3.99,
      merchant_id: @merchant_1.id
    }

    post "/api/v1/items", params:{item: attributes}
  
    item_new = JSON.parse(response.body, symbolize_names: true)

    id = item_new[:data][:id]

    get "/api/v1/items"

    all_items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(200)
    expect(item_new[:data][:attributes][:name]).to eq("chocolate bar")
  end
  
  it "can retrieve a single item by id" do
    id = @item_1.id
    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)
   
    expect(response.status).to eq(200)
    expect(item).to have_key(:data)
 
    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to be_a(String)

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to be_a(String)

    expect(item[:data]).to have_key(:attributes)
    attributes = item[:data][:attributes]
    
    expect(attributes).to have_key(:name)
    expect(attributes[:name]).to be_a(String)

    expect(attributes).to have_key(:description)
    expect(attributes[:description]).to be_a(String)

    expect(attributes).to have_key(:unit_price)
    expect(attributes[:unit_price]).to be_a(Float)

    expect(attributes).to have_key(:merchant_id)
    expect(attributes[:merchant_id]).to be_a(Integer)
  end

  it "can update an item by id" do
    previous_item = @item_1
    item_params = { name: "Test", description: "is successful", unit_price: 9.99, merchant_id: @merchant_2.id}
    headers = { "CONTENT_TYPE" => "application/json" }

    patch "/api/v1/items/#{@item_1.id}", headers: headers, params: JSON.generate({ item: item_params })

    changed_item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(changed_item[:data][:attributes][:name]).to eq("Test")
    expect(changed_item[:data][:attributes][:description]).to eq("is successful")
    expect(changed_item[:data][:attributes][:unit_price]).to eq(9.99)
    expect(changed_item[:data][:attributes][:merchant_id]).to eq(@merchant_2.id)
  end

  it "returns all items by price(low to high)" do 
    
    get "/api/v1/items?sorted=price" 

    items = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(response).to be_successful

    prices = items.map { |item| item[:attributes][:unit_price] }
    expect(prices).to eq(prices.sort)
  end

  it "returns a 404 error when trying to retrieve a non-existent item" do
    get "/api/v1/items/99999" 
  
    error_response = JSON.parse(response.body, symbolize_names: true)
  
    expect(response.status).to eq(404)
    expect(error_response[:message]).to eq("your query could not be completed")
  end

  it "returns a 404 error when trying to retrieve an item by a string" do
    get "/api/v1/items/test-item" 
  
    error_response = JSON.parse(response.body, symbolize_names: true)
  
    expect(response.status).to eq(404)
    expect(error_response[:message]).to eq("your query could not be completed")
  end
  
  it "returns a 404 error when trying to update a non-existent item" do
    item_params = { name: "Non-existent Item", description: "This won't work", unit_price: 1.99, merchant_id: @merchant_1.id }
    headers = { "CONTENT_TYPE" => "application/json"}
  
    patch "/api/v1/items/99999", headers: headers, params: JSON.generate({ item: item_params }) 
 
    error_response = JSON.parse(response.body, symbolize_names: true)
  
    expect(response.status).to eq(404)
    
    expect(error_response[:message]).to eq("your query could not be completed")
    expect(error_response[:errors].first[:status]).to eq("404")
    expect(error_response[:errors].first[:title]).to eq("your query could not be completed")
  end

  
  it "returns a 404 error when trying to delete a non-existent item" do
    delete "/api/v1/items/99999" 
  
    error_response = JSON.parse(response.body, symbolize_names: true)
  
    expect(response.status).to eq(404)
    expect(error_response[:message]).to eq("your query could not be completed")
  end

  it "returns 422 error if update fails due to validation errors" do
    patch "/api/v1/items/#{@item_1.id}", params: { item: { name: "" } }
        
    expect(response).to have_http_status(:unprocessable_entity)
    
    json_response = JSON.parse(response.body, symbolize_names: true)
    expect(json_response[:errors][0][:title]).to include("can't be blank")
  end

  describe "find all ITEMS based on search criteria" do
    it "can find all items by name" do
      @item_4 = Item.create!(name: "a baking mat", description: "Description 4", unit_price: 20.0, merchant: @merchant_3)

       get "/api/v1/items/find_all?name=bAk"

       items = JSON.parse(response.body, symbolize_names: true)

       expect(response).to be_successful
       expect(items).to be_an(Hash)
       expect(items[:data].count).to eq(2)
       expect(items[:data][0][:attributes][:name]).to eq(@item_4.name)
       expect(items[:data][1][:attributes][:name]).to eq(@item_3.name)
    end

    it "can find items by min_price" do
      get "/api/v1/items/find_all?min_price=50"

      items = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(items).to be_an(Hash)
      expect(items[:data].count).to eq(2)
      expect(items[:data][0][:attributes][:name]).to eq(@item_2.name)
      expect(items[:data][1][:attributes][:name]).to eq(@item_1.name)
    end

    it "can find items by max_price" do
      get "/api/v1/items/find_all?max_price=200"

      items = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(items).to be_an(Hash)
      expect(items[:data].count).to eq(2)
      expect(items[:data][0][:attributes][:name]).to eq(@item_1.name)
      expect(items[:data][1][:attributes][:name]).to eq(@item_3.name)
    end

    it 'can find items by min and max price' do
      get "/api/v1/items/find_all?max_price=200&min_price=21"

      items = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(items).to be_an(Hash)
      expect(items[:data].count).to eq(1)
      expect(items[:data][0][:attributes][:name]).to eq(@item_1.name)
    end

    it 'can render an empty array if no matches' do
      get "/api/v1/items/find_all?name=xxxxx"

      items = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      
      expect(items).to be_an(Hash)
      expect(items[:data]).to eq([])
      expect(items).to eq({:data=>[]})
    end

    it 'can handle errors in the query' do
      get "/api/v1/items/find_all?name="

      items = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:bad_request)
      expect(items[:errors][0][:status]).to eq("400")
    end
  end

  describe "POST /api/v1/items", type: :request do
    it "returns a 400 error with bad request response" do

      post "/api/v1/items", params: {}
  
      expect(response).to have_http_status(:bad_request)
  
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:message]).to eq("your query could not be completed")
      expect(json_response[:errors]).to be_an(Array)
      expect(json_response[:errors][0][:status]).to eq("400")
      expect(json_response[:errors][0][:title]).to include("param is missing")
    end
  end 

  describe "POST /api/v1/items with invalid JSON", type: :request do
    it "returns a 400 error for invalid JSON format" do
      post "/api/v1/items", params: "{ invalid json", headers: { "CONTENT_TYPE" => "application/json" }
  
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body, symbolize_names: true)
      expect(json_response[:errors][0][:title]).to eq("Invalid JSON format")
    end
  end

  describe "Can create items sad paths" do 
    it "can't create new items with no price" do 
      attributes = {
        name: "chocolate bar",
        description: "sweet and delicious",
        merchant_id: 1
      }
    
      post "/api/v1/items", params:{item: attributes}
        
      expect(response).to_not have_http_status(200)
    
      get "/api/v1/items"

      expect(response).to have_http_status(200)
    end

    it "can't create new items with no name" do 
      attributes = {
        description: "sweet and delicious",
        unit_price: 3.99,
        merchant_id: 1
      }
      
      post "/api/v1/items", params:{item: attributes}
          
      expect(response).to_not have_http_status(200)
      
      get "/api/v1/items"
  
      expect(response).to have_http_status(200)
    end

    it "can't create an item using the wrong class template" do 
      attributes = {
        name: "the chocolate bar guy",
      }

      post "/api/v1/items", params:{item: attributes}

      expect(response).to_not have_http_status(200)

      get "/api/v1/items"

      expect(response).to have_http_status(200)
    end
  end

  describe "can't delete same item twice" do
    it "can not delete same item twice" do

    delete "/api/v1/merchants/#{@item_1.id}"
    delete "/api/v1/merchants/#{@item_1.id}"

    expect(response).to have_http_status(:not_found)
    end
  end
end