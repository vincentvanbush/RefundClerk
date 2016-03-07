require 'rails_helper'

RSpec.feature "RefundRequests", type: :feature do
  let!(:users) { FactoryGirl.create_list :user, 2 }
  let!(:admin) { FactoryGirl.create :user, email: 'a@dmin.pl',
                                    password: 'admin123',
                                    admin: true }
  let!(:categories) { FactoryGirl.create_list :category, 2 }
  before do
    users.each do |u|
      categories.each { |c| FactoryGirl.create :refund_request,
                            category: c, user: u, status: RefundRequest.count % 2 }
    end
  end

  context 'index' do
    context 'when logged in as admin' do
      before { sign_in 'a@dmin.pl', 'admin123'
               visit '/' }
      it 'contains all refund requests' do
        RefundRequest.all.each { |r| expect(page).to have_content(r.title) }
      end
    end

    context 'when logged in as normal user' do
      before { sign_in users.first.email, users.first.password
               visit '/' }
      it 'contains only that user\'s request' do
        users.first.refund_requests.each { |r| expect(page).to have_content(r.title) }
        users.second.refund_requests.each { |r| expect(page).not_to have_content(r.title) }
      end
    end

    context 'filtering' do
      before { sign_in 'a@dmin.pl', 'admin123' 
               visit '/' }

      context 'has links to filter' do
        it 'by category' do
          categories.each do |c|
            expect(page).to have_link(c.title, href: refund_requests_path(category: c))
          end
        end

        it 'by user' do
          users.each do |u|
            expect(page).to have_link(u.full_name, href: refund_requests_path(user: u))
          end
        end

        it 'by status' do
          RefundRequest.all.each do |r|
            expect(page).to have_link(r.status, href: refund_requests_path(status: r.status))
          end
        end
      end
      
      context 'after applied' do
        let(:refund_request) { RefundRequest.find_by(category: categories.first,
                                                     user: users.first,
                                                     status: 'pending') }
        before do
          first(:link, categories.first.title).click
          first(:link, users.first.full_name).click
          first(:link, refund_request.status).click
        end
        subject { page }

        describe 'creates links to remove filters' do
          it { is_expected.to have_css("a:contains('Category:', '#{categories.first.title}')") }
          it { is_expected.to have_css("a:contains('User:', '#{users.first.full_name}')") }
          it { is_expected.to have_css("a:contains('status:', '#{refund_request.status}')") }
        end

        describe 'filters out non-matching records' do
          it { is_expected.not_to have_content(categories.second) }
          it { is_expected.not_to have_content(users.second) }
          it { is_expected.not_to have_content('accepted') }
        end
        
      end
    end
  end

end
