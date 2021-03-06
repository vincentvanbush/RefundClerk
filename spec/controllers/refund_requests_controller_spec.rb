require 'rails_helper'

RSpec.describe RefundRequestsController, type: :controller do
  let(:users) { FactoryGirl.create_list :user, 2 }
  let(:category) { FactoryGirl.create :category }
  let(:admin) { FactoryGirl.create :user, admin: true }
  let(:request_params) { Hash.new }
  before do
    users.each do |user|
      FactoryGirl.create :refund_request, category: category, user: user
    end
  end

  subject { response }

  describe 'GET #index' do
    it_has_behavior 'renders devise/sessions/new if not logged in', :get, :index

    context 'when logged in as an user' do
      before { controller.stub(:current_user).and_return(users.first) }
      it_has_behavior 'successfully renders template', :get, :index
    end

    context 'when logged in as admin' do
      before { controller.stub(:current_user).and_return(admin) }
      it_has_behavior 'successfully renders template', :get, :index
    end
  end

  describe 'GET #show' do
    let(:request_params) { { id: RefundRequest.first.id } }
    it_has_behavior 'renders devise/sessions/new if not logged in', :get, :show

    context 'when logged in as an user' do
      context 'and accessing that user\'s item' do
        let(:request_params) { { id: users.first.refund_requests.first } }
        before { controller.stub(:current_user).and_return(users.first) }
        it_has_behavior 'successfully renders template', :get, :show
      end

      context 'and accessing another user\'s item' do
        before { controller.stub(:current_user).and_return(users.first)
                 get :show, id: users.second.refund_requests.first }
        it { is_expected.to have_http_status(302) }
      end
    end

    context 'when logged in as admin' do
      let(:request_params) { { id: users.second.refund_requests.first } }
      before { controller.stub(:current_user).and_return(admin) }
      it_has_behavior 'successfully renders template', :get, :show
    end
  end

  describe 'GET #new' do
    it_has_behavior 'renders devise/sessions/new if not logged in', :get, :new

    context 'when logged in' do
      before { controller.stub(:current_user).and_return(users.first) }
      it_has_behavior 'successfully renders template', :get, :new
    end
  end

  describe 'POST #create' do
    let(:request_params) { { refund_request:
                               FactoryGirl.attributes_for(:refund_request,
                               category_id: category.id)
                             } }
    it_has_behavior 'renders devise/sessions/new if not logged in', :post, :create

    context 'when logged in' do
      before { controller.stub(:current_user).and_return(users.first) }
      it 'creates a record' do
        expect { post :create, request_params }
          .to change { users.first.refund_requests.count }.by(1)
      end
    end
  end

  describe 'PATCH #update' do
    let(:request_params) { { id: users.first.refund_requests.first.id,
                             refund_request: { title: 'blabla' } } }
    it_has_behavior 'renders devise/sessions/new if not logged in', :patch, :update

    context 'when logged in' do
      context 'as the item\'s owner' do
        before { controller.stub(:current_user).and_return(users.first)
                 patch :update, request_params }
        it { is_expected.to have_http_status(200) }
        it 'should update the item' do
          expect(users.first.refund_requests.first.title).to eql('blabla')
        end
      end

      context 'as someone else' do
        before { controller.stub(:current_user).and_return(users.second)
                 patch :update, request_params }
        it { is_expected.to have_http_status(302) }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:request_params) { { id: users.first.refund_requests.first.id } }
    it_has_behavior 'renders devise/sessions/new if not logged in', :delete, :destroy

    context 'when logged in' do
      context 'as the item\'s owner' do
        before { controller.stub(:current_user).and_return(users.first)
                 delete :destroy, request_params }
        it { is_expected.to redirect_to(refund_requests_url) }
        it 'should delete the item' do
          expect(users.first.refund_requests.count).to eq(0)
        end
      end

      context 'as admin' do
        before { controller.stub(:current_user).and_return(admin)
                 delete :destroy, request_params }
        it { is_expected.to redirect_to(refund_requests_url) }
        it 'should delete the item' do
          expect(users.first.refund_requests.count).to eq(0)
        end
      end

      context 'as someone else' do
        before { controller.stub(:current_user).and_return(users.second)
                 delete :destroy, request_params }
        it { is_expected.to have_http_status(302) }
        it 'should not delete the item' do
          expect(users.first.refund_requests.count).to eq(1)
        end
      end
    end
  end

end
