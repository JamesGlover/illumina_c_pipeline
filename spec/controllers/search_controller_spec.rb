require 'rails_helper'
require './app/controllers/search_controller'

describe SearchController, type: :controller do

  describe 'POST' do
    describe 'qcables' do

      has_a_working_api
      stub_request_and_response('find-qcable-by-barcode-uuid')
      stub_request_and_response('post-to-find-qcable-by-barcode-uuid')

      Settings.searches['Find qcable by barcode'] = 'find-qcable-by-barcode-uuid'

      it 'redirects to the qcable page' do
        post :qcables, qcable_barcode: "3980681751743", format: :json
        expect(response).to redirect_to(tag_plate_path("tag2-qcable-uuid"))
      end
    end
  end
end
