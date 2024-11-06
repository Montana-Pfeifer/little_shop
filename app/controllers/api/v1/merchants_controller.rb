class Api::V1::MerchantsController < ApplicationController   
rescue_from ActiveRecord::RecordNotFound, with: :not_found_error_response
rescue_from ActionController::ParameterMissing, with: :bad_request_error_response
rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_parse_error
before_action :validate_name_param, only: [:find_one]
    def index
        merchants = Merchant.fetch_merchants(params)
        render json: MerchantSerializer.new(merchants, { params: { count: params[:count], sorted: params[:sorted] } })
    end

    def show
        merchant = Merchant.find(params[:id])
        render json: MerchantSerializer.new(merchant)
    end
    
    def update
        merchant = Merchant.find(params[:id])
        if merchant.update(merchant_params)
            render json: MerchantSerializer.new(merchant), status: :ok
        end
    end

    def destroy
        merchant = Merchant.find_by(id: params[:id])
        if merchant
          merchant.destroy
          render json: { message: 'Merchant successfully deleted' }, status: :ok
        else
          render json: { error: 'Merchant not found' }, status: :not_found
        end
      end
   
    def create
        merchant =  Merchant.create!(merchant_params)
        render json: MerchantSerializer.new(merchant), status: :created
    end  

    def find_one
        merchant = Merchant.find_one_by_name(params)
        if merchant.nil?
            render json:    
            { data: {}    
            }
        else
        render json: MerchantSerializer.new(merchant)
        end
    end

    private
        
    def merchant_params
        params.require(:merchant).permit(:name)
    end

    def not_found_error_response(error)
        render json: ErrorSerializer.new(ErrorMessage.new(error.message, 404)).serialize_json, status: :not_found
    end

    def bad_request_error_response(error)
        render json: ErrorSerializer.new(ErrorMessage.new(error.message, 400)).serialize_json, status: :bad_request
    end

    def handle_parse_error(error)
        render json: ErrorSerializer.new(ErrorMessage.new("Invalid JSON format", 400)).serialize_json, status: :bad_request
    end

    def validate_name_param
        if params[:name] == "" || params[:name].nil?
            render json:    {
                errors: [
                  {
                    status: "400",
                    message: "Invalid parameters"
                  }
                ]
              },
              status: :bad_request
        end
    end
end