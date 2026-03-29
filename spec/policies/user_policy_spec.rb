# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy do
  subject(:policy) { described_class.new(pundit_user, record) }

  let(:record) { user }

  context "when the user is an admin" do
    let(:user) { build(:user, :admin) }
    let(:pundit_user) { user }

    it "allows access to the admin area" do
      expect(policy.access_admin?).to be true
    end
  end

  context "when the user is a regular user" do
    let(:user) { build(:user) }
    let(:pundit_user) { user }

    it "denies access to the admin area" do
      expect(policy.access_admin?).to be false
    end
  end
end
