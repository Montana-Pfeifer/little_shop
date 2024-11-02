class MerchantInvoiceSerializer
    include JSONAPI::Serializer
    attributes :customer_id, :merchant_id, :status
end