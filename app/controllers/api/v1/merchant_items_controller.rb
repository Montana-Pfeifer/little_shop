class Api::V1::MerchantItemsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, with: :not_found_error_response
     def index
        merchant =Merchant.find(params[:id])
        items = merchant.items
        render json: ItemSerializer.new(items)
     end

    private 
    
     def not_found_error_response(error)
        render json: ErrorSerializer.new(ErrorMessage.new(error.message, 404)).serialize_json, status: :not_found
    end
end