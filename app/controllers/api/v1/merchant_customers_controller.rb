class Api::V1::MerchantCustomersController < ApplicationController
before_action :validate_merchant, only: [:index]

    def index
        customers = Customer.show_all_customers(params[:id])
        render json: CustomerSerializer.new(customers)
    end

    private

    def validate_merchant
        merchant = Merchant.find_by(id: params[:id])
        if merchant == nil
            error_message = ErrorMessage.new("Merchant not found", 404)
            render json: ErrorSerializer.new(error_message).serialize_json, status: :not_found
        end
    end
end