require 'rails_helper'
require './app/controllers/multiple_target_state_change_controller'

describe MultipleTargetStateChangeController, type: :controller do

  describe "state change for multiple tubes" do

    has_a_working_api
    stub_request_and_response('multiplexed-library-tube-uuid')
    stub_request_and_response('multiplexed-library-tube-2-uuid')
    stub_request_and_response('state-change-tube-to-passed')
    stub_request_and_response('state-change-tube-2-to-passed')

    before(:each) do
      Settings.purposes['ilc-lib-pool-norm-uuid']= {state_changer_class: 'StateChangers::DefaultStateChanger'}
    end

    it "creates state changes if tubes to pass were chosen" do
      req = post :create, {tubes: {"multiplexed-library-tube-uuid" => "multiplexed-library-tube-ean13-barcode", "multiplexed-library-tube-2-uuid" => "multiplexed-library-tube-2-ean13-barcode"}}, user_uuid: "user-uuid", format: :json
      expect(response).to redirect_to(search_path)
    end

  end

  describe "state change if no tubes chosen" do

    has_a_working_api

    it "redirects to serch if no tubes were chosen" do
      post :create, tubes: {}, format: :json
      expect(response).to redirect_to(search_path)
    end

  end

end