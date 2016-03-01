require 'rails_helper'

RSpec.describe RefundRequest, type: :model do
  let(:user) { FactoryGirl.create :user }
  let(:category) { FactoryGirl.create :category }
  let(:refund_request) { FactoryGirl.create :refund_request,
                                            user_id: user.id,
                                            category_id: category.id }
  subject { refund_request }

  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :category }
  end

  describe 'fields' do
    it { is_expected.to respond_to :amount }
    it { is_expected.to respond_to :status }
    it { is_expected.to define_enum_for(:status)
                        .with([:pending, :accepted, :rejected]) }
    it { is_expected.to respond_to :title }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :rejection_reason }
  end

  describe 'with all valid values' do
    it { is_expected.to be_valid }
  end

  describe 'with no category' do
    before { refund_request.category = nil }
    it { is_expected.not_to be_valid }
  end

  describe 'with no user' do
    before { refund_request.user = nil }
    it { is_expected.not_to be_valid }
  end

  describe 'with no status' do
    before { refund_request.status = nil }
    it { is_expected.not_to be_valid }
  end

  describe 'with no title' do
    before { refund_request.title = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'with too long title' do
    before { refund_request.title = 'a' * 51 }
    it { is_expected.not_to be_valid }
  end

  describe 'with no description' do
    before { refund_request.description = '' }
    it { is_expected.not_to be_valid }
  end

  describe 'without rejection reason when status is rejected' do
    before { refund_request.rejection_reason = ''
             refund_request.status = "rejected" }
    it { is_expected.not_to be_valid }
  end

  describe 'with specified rejection reason when status is rejected' do
    before { refund_request.rejection_reason = 'because of reasons'
             refund_request.status = "rejected" }
    it { is_expected.to be_valid }
  end

end
