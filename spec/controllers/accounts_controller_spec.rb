require 'rails_helper'

RSpec.describe AccountsController, type: :controller do

  let(:valid_attributes) {
    attributes_for :account
  }

  let(:invalid_attributes) {
    attributes_for :account, name: nil
  }

  let(:api_key_param) { { api_key: "vigilion" } }

  describe "GET #index" do
    it "assigns all accounts as @accounts" do
      account = create(:account)
      get :index, {}.merge(api_key_param)
      expect(assigns(:accounts)).to eq([account])
    end
  end

  describe "GET #show" do
    it "assigns the requested account as @account" do
      account = create(:account)
      get :show, {:id => account.to_param}.merge(api_key_param)
      expect(assigns(:account)).to eq(account)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Account" do
        expect {
          post :create, {:account => valid_attributes}.merge(api_key_param)
        }.to change(Account, :count).by(1)
      end

      it "assigns a newly created account as @account" do
        post :create, {:account => valid_attributes}.merge(api_key_param)
        expect(assigns(:account)).to be_a(Account)
        expect(assigns(:account)).to be_persisted
      end

      it "returns 201 (created)" do
        post :create, {:account => valid_attributes}.merge(api_key_param)
        expect(response).to be_created
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved account as @account" do
        post :create, {:account => invalid_attributes}.merge(api_key_param)
        expect(assigns(:account)).to be_a_new(Account)
      end

      it "returns 422 (unprocessable entity)" do
        post :create, {:account => invalid_attributes}.merge(api_key_param)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "updates the requested account" do
        account = create(:account)
        new_attributes = valid_attributes
        put :update, {:id => account.to_param, :account => new_attributes}.merge(api_key_param)
        account.reload
        expect(account.name).to eq new_attributes[:name]
      end

      it "assigns the requested account as @account" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => valid_attributes}.merge(api_key_param)
        expect(assigns(:account)).to eq(account)
      end

      it "returns 200 (OK)" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => valid_attributes}.merge(api_key_param)
        expect(response).to be_ok
      end
    end

    context "with invalid params" do
      it "assigns the account as @account" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => invalid_attributes}.merge(api_key_param)
        expect(assigns(:account)).to eq(account)
      end

      it "returns 422 (unprocessable entity)" do
        account = create(:account)
        put :update, {:id => account.to_param, :account => invalid_attributes}.merge(api_key_param)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested account" do
      account = create(:account)
      expect {
        delete :destroy, {:id => account.to_param}.merge(api_key_param)
      }.to change(Account, :count).by(-1)
    end

    it "returns 204 (no content)" do
      account = create(:account)
      delete :destroy, {:id => account.to_param}.merge(api_key_param)
      expect(response.status).to eq(204)
    end
  end
end
