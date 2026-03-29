# frozen_string_literal: true

require "rails_helper"

RSpec.describe Drink, type: :model do
  describe "validations" do
    subject { build(:drink) }

    it { is_expected.to be_valid }

    it "requires a name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "requires a unique name" do
      create(:drink, name: "Latte")
      subject.name = "Latte"
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("has already been taken")
    end

    it "requires a base_price" do
      subject.base_price = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:base_price]).to include("can't be blank")
    end

    it "requires base_price to be non-negative" do
      subject.base_price = -1
      expect(subject).not_to be_valid
      expect(subject.errors[:base_price]).to include("must be greater than or equal to 0")
    end

    it "allows a base_price of zero" do
      subject.base_price = 0
      expect(subject).to be_valid
    end

    it "rejects a base_price that exceeds the database column limit" do
      subject.base_price = 1_000_000
      expect(subject).not_to be_valid
      expect(subject.errors[:base_price]).to include("must be less than 1000000")
    end
  end
end
