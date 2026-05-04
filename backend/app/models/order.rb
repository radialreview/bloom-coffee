class Order < ActiveRecord::Base
  ORDER_NUMBER_LOCK_ID = 19_840_504

  has_many :order_items, dependent: :destroy

  validates :customer_name, presence: true, length: { maximum: 120 }
  validates :order_number, presence: true, uniqueness: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }

  before_validation :assign_order_number, on: :create

  def as_api_json
    {
      id: id,
      public_token: public_token,
      order_number: order_number,
      customer_name: customer_name,
      total: total.to_f.round(2),
      items: order_items.includes(:drink, order_item_add_ons: :add_on).order(:id).map(&:as_api_json),
      created_at: created_at&.utc&.iso8601,
    }
  end

  private

  def assign_order_number
    return if order_number.present?

    self.order_number = self.class.next_order_number
    self.public_token ||= SecureRandom.urlsafe_base64(16)
  end

  def self.next_order_number
    adapter = connection.adapter_name.downcase
    if adapter.include?("postgresql")
      connection.execute("SELECT pg_advisory_xact_lock(#{ORDER_NUMBER_LOCK_ID})")
    end

    last_number = maximum(:order_number) || 999
    last_number + 1
  end
end
