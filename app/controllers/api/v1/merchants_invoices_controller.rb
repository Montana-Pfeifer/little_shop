class Api::V1::MerchantsInvoicesController < ApplicationController
    ALLOWED_STATUSES = ["shipped", "returned", "packaged"].freeze
    #makes an unchangeable array of the allowed statuses for invoices

    def index   # handling 'get' api/v1/merchants/:merchant_id/invoices    
        status = params[:status]

        #finding the invoices
        if status.present?
            invoices = Invoice.where(merchant_id: params[:merchant_id], status: status)
        else
            invoices = Invoice.where(merchant_id: params[:merchant_id], status: ALLOWED_STATUSES)
        end
        #render invoices into the right format
        render json: MerchantInvoiceSerializer.new(invoices)
   
    end
    
            

end