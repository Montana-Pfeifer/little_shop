class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  attribute :item_count, if: Proc.new { |merchant, params| params[:count] == 'true' && merchant.respond_to?(:item_count) }
  attribute :created_at, if: Proc.new { |_, params| params[:sorted] == 'age' }

end
