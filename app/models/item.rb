class Item < ApplicationRecord
belongs_to :merchants
has_many :invoice_items
end