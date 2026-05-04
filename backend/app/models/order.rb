class Order < ActiveRecord::Base
  has_many :order_items, dependent: :destroy

  validates :customer_name, presence: true
  validates :order_number, presence: true, uniqueness: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }

  before_validation :assign_order_number, on: :create

  def as_api_json
    {
      id: id,
      order_number: order_number,
      customer_name: customer_name,
      total: total.to_f.round(2),
      items: order_items.includes(:drink, :order_item_add_ons, :add_ons).order(:id).map(&:as_api_json),
      created_at: created_at&.utc&.iso8601,
    }
  end

  private

  def assign_order_number
    return if order_number.present?

    self.order_number = self.class.next_order_number
  end

  def self.next_order_number
    adapter = connection.adapter_name.downcase
    if adapter.include?("postgresql")
      connection.execute("SELECT pg_advisory_xact_lock(42)")
    end

    (maximum(:order_number) || 999) + 1
  end
end
