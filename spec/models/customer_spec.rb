require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe "Associations" do
    it { should have_many :invoices }
  end

  describe 'Validations' do 
    it {should validate_presence_of(:first_name) }
    it {should validate_presence_of(:last_name) }
  end
end