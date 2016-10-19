require 'rails_helper'

RSpec.describe "Pass all tubes", type: :feature, js: true do

  describe "user logged in" do

    has_a_working_api(5)

    stub_request_and_response('find-user-by-swipecard-uuid')
    stub_request_and_response('find-user-by-swipecard-first')
    stub_request_and_response('find-assets-by-barcode-uuid')
    stub_request_and_response('find-assets-by-barcode-first')
    stub_request_and_response('final-plate-uuid', 2)
    stub_request_and_response('final-plate-wells')
    stub_request_and_response('barcode-printers')
    stub_request_and_response('final-plate-qc-files')
    stub_request_and_response('ilc-al-libs-tagged-uuid')
    stub_request_and_response('ilc-al-libs-tagged-children')
    stub_request_and_response('final-plate-comments')

    Settings.searches['Find user by swipecard code'] = 'find-user-by-swipecard-uuid'
    Settings.searches['Find assets by barcode'] = 'find-assets-by-barcode-uuid'

    describe "some tubes are not passed " do

      stub_request_and_response('final-plate-transfers-to-tubes-all-pending-or-started')
      stub_request_and_response('multiplexed-library-tube-uuid')
      stub_request_and_response('multiplexed-library-tube-2-uuid')
      stub_request_and_response('state-change-tube-to-passed')
      stub_request_and_response('state-change-tube-2-to-passed')

      before(:each) do
        Settings.purposes['ilc-lib-pool-norm-uuid']= {state_changer_class: 'StateChangers::DefaultStateChanger'}
        Settings.purposes['ilc-al-libs-tagged-uuid']= {presenter_class: 'Presenters::QCTaggedPresenter'}
        Settings.purposes['ilc-qc-pool-uuid'] = {}
        Settings.qc_purposes = ['ILC QC Pool']
      end

      it "allows to pass several tubes" do

        visit search_path
        fill_in 'User Swipecard:', with: 'abcdef'
        fill_in 'Plate or Tube Barcode:', :with => '0123456789012'
        find('.plate-barcode').native.send_key(:Enter)
        expect(page).to have_content 'Pooled Plate'
        expect(all('input[type=checkbox]').count).to eq 4
        expect(all('input[type=checkbox]').any? {|el| el.disabled?}).to be false
        expect(all('input[type=checkbox]').all? {|el| el.checked?}).to be true
        all('input[type=checkbox]')[2].set(false)
        all('input[type=checkbox]').last.set(false)
        expect(all('input[type=checkbox]').last.checked?).to be false
        expect(all('input[type=checkbox]')[2].checked?).to be false
        click_button('Pass all tubes')
        expect(page).to have_content "Labware: tube-1-ean13, tube-2-ean13 have been changed to a state of Passed"
      end

    end

    describe "all tubes are passed " do

      stub_request_and_response('final-plate-transfers-to-tubes-all-passed')

      it "informs that there is nothing to pass" do

        visit search_path
        fill_in 'User Swipecard:', with: 'abcdef'
        fill_in 'Plate or Tube Barcode:', :with => '0123456789012'
        find('.plate-barcode').native.send_key(:Enter)
        expect(page).to have_content 'Pooled Plate'
        expect(all('input[type=checkbox]').count).to eq 4
        expect(all('input[type=checkbox]').all? {|el| el.disabled?}).to be true
        click_button('Pass all tubes')
        expect(page).to have_content 'Nothing to pass'
      end

    end

  end

  describe "user didn't log in" do

    has_a_working_api

    stub_request_and_response('final-plate-uuid', 2)
    stub_request_and_response('final-plate-wells')
    stub_request_and_response('barcode-printers')
    stub_request_and_response('final-plate-qc-files')
    stub_request_and_response('ilc-al-libs-tagged-uuid')
    stub_request_and_response('ilc-al-libs-tagged-children')
    stub_request_and_response('final-plate-comments')
    stub_request_and_response('final-plate-transfers-to-tubes-all-pending-or-started')

    it "does not allow to pass all tubes" do
      visit illumina_c_plate_path("final-plate-uuid")
      expect(page).to have_content 'Pooled Plate'
      Capybara.ignore_hidden_elements = false
      expect(page).to have_button('Pass all tubes', disabled: true)
    end

  end

end
