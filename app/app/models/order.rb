class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  enum :status, { in_progress: 0, submitted: 1 }

  validates :customer_name, presence: true, if: :submitted?

  before_save :snapshot_total_price, if: -> { submitted? && total_price.blank? }

  def total
    total_price || calculate_total
  end

  def calculate_total
    order_items.includes(:drink, :add_ons).sum(&:line_total)
  end

  def item_count
    order_items.sum(:quantity)
  end

  def order_number
    "##{id}"
  end

  private

  def snapshot_total_price
    self.total_price = calculate_total
  end
end
