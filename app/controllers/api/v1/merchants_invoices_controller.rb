class Api::V1::MerchantsInvoicesController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_error_response
    ALLOWED_STATUSES = ["shipped", "returned", "packaged"].freeze

    def index  
        status = params[:status]
        Merchant.find(params[:merchant_id])

        if status.present?
            invoices = Invoice.where(merchant_id: params[:merchant_id], status: status)
        else
            invoices = Invoice.where(merchant_id: params[:merchant_id], status: ALLOWED_STATUSES)
        end
        render json: MerchantInvoiceSerializer.new(invoices)   
    end
    
    def not_found_error_response(error)
        render json: ErrorSerializer.new(ErrorMessage.new(error.message, 404)).serialize_json, status: :not_found
    end           
end