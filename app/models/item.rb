class Item < ApplicationRecord
belongs_to :merchant
has_many :invoice_items
has_many :invoices, through: :invoice_items

validates :name, :description, :unit_price, presence: true

    def self.sorted_by_price
        order(:unit_price)
    end

    def self.find_all_items(params)
        name_input = params[:name]
        min_input = params[:min_price]
        max_input = params[:max_price]

        if params[:min_price].present? && params[:max_price].present?
            where("unit_price >= ? AND unit_price <= ?", min_input, max_input).order("LOWER(name)")
        elsif params[:min_price].present?
            where("unit_price >= ?", min_input).order("LOWER(name)")
        elsif params[:max_price].present?
            where("unit_price <= ?",max_input).order("LOWER(name)")
        else
            where("name ILIKE ?", "%#{name_input}%").order("LOWER(name)")
        end
    end
end