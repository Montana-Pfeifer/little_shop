class Api::V1::ItemsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, with: :not_found_error_response
rescue_from ActionController::ParameterMissing, with: :bad_request_error_response
rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_parse_error
rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_error
before_action :validate_find_params, only: [:find_all]

    def index
        items = fetch_items
        render json: ItemSerializer.new(items)
    end

    def show
        item = Item.find(params[:id])
        render json: ItemSerializer.new(item)
    end

    def update
  item = Item.find(params[:id])

  if item.update(item_params)
    render json: ItemSerializer.new(item), status: :ok
  else
    record_invalid_error_response(item)
  end
end

    def destroy
        Item.find(params[:id]).destroy
    end

    def create
        item = Item.create!(item_params)
        render json: ItemSerializer.new(item), status: :created
    end

    def find_all
        items = Item.find_all_items(params)
        render json: ItemSerializer.new(items)
    end

    private 

    def fetch_items
        params[:sorted].presence == 'price' ? Item.sorted_by_price : Item.all
    end

    def item_params
        params.require(:item).permit( :merchant_id,:unit_price, :name, :description)
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

    def record_invalid_error_response(item)
        render json: ErrorSerializer.new(ErrorMessage.new(item.errors.full_messages.join(', '), 422)).serialize_json, status: :unprocessable_entity
    end
    
    def validate_find_params
        invalid_params = {
            errors: [
              {
                status: "400",
                message: "Invalid parameters"
              }
            ]
          }
          if (params[:max_price].present? && params[:max_price].to_f < 0) ||
            (params[:min_price].present? && params[:min_price].to_f < 0) ||
            (params[:name].present? && (params[:min_price].present? || params[:max_price].present?)) ||
            (params[:max_price].present? && params[:max_price] == "") ||
            (params[:min_price].present? && params[:min_price] == "") ||
            ([params[:max_price], params[:min_price], params[:name]].all?(&:nil?) ||
             [params[:max_price], params[:min_price]].all?(&:nil?) && params[:name] == "")
           render json: invalid_params, status: :bad_request
         end
    end
end


