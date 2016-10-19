require 'rails_helper'
require './app/models/forms/tagging_form'

describe Forms::TaggingForm do

  has_a_working_api
  # We retrieve the plate during initialization to set up the pools
  stub_request_and_response('ilc-stock-plate')
  # We retrieve the wells as part of this.
  stub_request_and_response('ilc-stock-plate-wells')

  let(:wells_in_column_order) { (1..12).map {|c| ('A'..'H').map {|r| "#{r}#{c}" }}.flatten }

  context "On new" do
    let(:tagging_form) {
      Forms::TaggingForm.new(
        :purpose_uuid=>"ilc-al-libs-tagged-uuid",
        :parent_uuid=>"ilc-stock-plate-uuid",
        :api       => api
      )
    }

    # These values all describe the returned json.
    # They are used to prevent magic numbers from appearing in the specs
    let(:plate_size) { 96 }
    let(:occupied_wells) { 30 }
    let(:pool_size) { 15 }
    let(:largest_tag_group) { 120 }

    let(:maximum_tag_offset)  { largest_tag_group - occupied_wells }
    let(:maximum_well_offset) { plate_size - occupied_wells + 1 }

    it 'can be created' do
      expect(tagging_form).to be_a Forms::TaggingForm
    end

    context 'with purpose mocks' do
      stub_request_and_response('ilc-al-libs-tagged-uuid')
      it 'describes the child purpose' do
        expect(tagging_form.child_purpose.name).to eq('ILC AL Libs Tagged')
      end
    end

    it 'describes the parent barcode' do
      expect(tagging_form.labware.barcode.ean13).to eq('1220427444877')
    end

    it 'describes the parent uuid' do
      expect(tagging_form.parent_uuid).to eq('ilc-stock-plate-uuid')
    end

    it 'describes the purpose uuid' do
      expect(tagging_form.purpose_uuid).to eq('ilc-al-libs-tagged-uuid')
    end

    context 'with tag groups available' do
      stub_request_and_response('tag-groups')
      it 'describes the available tag groups' do
        expect(tagging_form.tag_groups_with_uuid).to eq([["Suitably big group", "tag-group-c-uuid"]])
      end
      it 'describes the tag_range' do
        expect(tagging_form.tag_range).to eq((0..maximum_tag_offset).map {|i| [i+1,i] } )
      end
      it 'describes tags by name' do
        expect(tagging_form.tags_by_name).to eq({"Suitably big group"=>(1..largest_tag_group).to_a})
      end
    end

    it 'describes wells by column' do
      expect(tagging_form.wells_by_column_mapping).to eq([[0, "passed", "pool-1-uuid"], [1, "passed", "pool-1-uuid"], [2, "passed", "pool-1-uuid"], [3, "passed", "pool-1-uuid"], [4, "passed", "pool-1-uuid"], [5, "passed", "pool-1-uuid"], [6, "passed", "pool-1-uuid"], [7, "passed", "pool-1-uuid"], [8, "passed", "pool-1-uuid"], [9, "passed", "pool-1-uuid"], [10, "passed", "pool-1-uuid"], [11, "passed", "pool-1-uuid"], [12, "passed", "pool-1-uuid"], [13, "passed", "pool-1-uuid"], [14, "passed", "pool-1-uuid"], [15, "passed", "pool-2-uuid"], [16, "passed", "pool-2-uuid"], [17, "passed", "pool-2-uuid"], [18, "passed", "pool-2-uuid"], [19, "passed", "pool-2-uuid"], [20, "passed", "pool-2-uuid"], [21, "passed", "pool-2-uuid"], [22, "passed", "pool-2-uuid"], [23, "passed", "pool-2-uuid"], [24, "passed", "pool-2-uuid"], [25, "passed", "pool-2-uuid"], [26, "passed", "pool-2-uuid"], [27, "passed", "pool-2-uuid"], [28, "passed", "pool-2-uuid"], [29, "passed", "pool-2-uuid"]])
    end
    it 'describes wells by row' do
      expect(tagging_form.wells_by_row_mapping).to eq([[0, "passed", "pool-1-uuid"], [1, "passed", "pool-1-uuid"], [2, "passed", "pool-2-uuid"], [3, "passed", "pool-2-uuid"], [12, "passed", "pool-1-uuid"], [13, "passed", "pool-1-uuid"], [14, "passed", "pool-2-uuid"], [15, "passed", "pool-2-uuid"], [24, "passed", "pool-1-uuid"], [25, "passed", "pool-1-uuid"], [26, "passed", "pool-2-uuid"], [27, "passed", "pool-2-uuid"], [36, "passed", "pool-1-uuid"], [37, "passed", "pool-1-uuid"], [38, "passed", "pool-2-uuid"], [39, "passed", "pool-2-uuid"], [48, "passed", "pool-1-uuid"], [49, "passed", "pool-1-uuid"], [50, "passed", "pool-2-uuid"], [51, "passed", "pool-2-uuid"], [60, "passed", "pool-1-uuid"], [61, "passed", "pool-1-uuid"], [62, "passed", "pool-2-uuid"], [63, "passed", "pool-2-uuid"], [72, "passed", "pool-1-uuid"], [73, "passed", "pool-1-uuid"], [74, "passed", "pool-2-uuid"], [84, "passed", "pool-1-uuid"], [85, "passed", "pool-2-uuid"], [86, "passed", "pool-2-uuid"]])
    end

    it 'describes the offsets' do
      expect(tagging_form.offsets).to eq(wells_in_column_order.slice(0,maximum_well_offset).each_with_index.map {|w,i| [w,i]} )
    end

    context 'when a submission is split over multiple plates' do

      stub_request_from("retrieve-ilc-stock-plate-submission-pools") { response('ilc-stock-plate-submission-pools-dual') }

      it 'requires tag2' do
        expect(tagging_form.requires_tag2?).to be true
      end

      context 'with advertised tag2 templates' do

        stub_request_and_response('tag2-layout-templates')

        it 'describes only the unused tube' do
          expect(tagging_form.tag2s.keys).to eq(['unused-tag2-template-uuid'])
          expect(tagging_form.tag2_names).to eq(['Unused template'])
        end
      end
    end

    context 'when a submission is not split over multiple plates' do

      stub_request_from("retrieve-ilc-stock-plate-submission-pools") { response('ilc-stock-plate-submission-pools-single') }

      it 'does not require tag2' do
        expect(tagging_form.requires_tag2?).to be false
      end

    end

  end

  context "On create" do
    context "With no tag 2" do

      let(:tagging_form) {
        Forms::TaggingForm.new(
          :purpose_uuid=>"ilc-al-libs-tagged-uuid",
          :parent_uuid=>"ilc-stock-plate-uuid",
          :tag_group_uuid=>"tag-group-uuid",
          :walking_by=>"manual by plate",
          :direction=>"column",
          :offset=>"0",
          :tag_start=>"1",
          :api       => api,
          :user_uuid => "user-uuid"
        )
      }

      it 'can be created' do
        expect(tagging_form).to be_a Forms::TaggingForm
      end

      it 'renders the "tagging" page' do
        controller = CreationController.new
        expect(controller).to receive(:render).with('tagging')
        tagging_form.render(controller)
      end

      context 'on save!' do
        # Create the al-libs-tagged plate
        stub_request_and_response('plate-creation-ilc-al-libs-tagged')
        # Fetch the custom transfer template
        stub_request_and_response('custom-plate-transfer-template')
        # Then create a new transfer using it
        stub_request_and_response('custom-plate-transfer-to-ilc-al-libs-tagged')
        # Apply the tag-group to the whole plate with no offset, starting at 1.
        stub_request_and_response('tag-layout-creation-a')

        Settings.transfer_templates['Custom pooling'] = 'custom-plate-transfer-template-uuid'

        it 'creates a tag plate' do
          tagging_form.save!
        end

        it 'has the correct child (and uuid)' do
          tagging_form.save!
          expect(tagging_form.child.uuid).to eq('ilc-al-libs-tagged-plate-uuid')
        end
      end
    end

    context "With tag 2" do

      let(:tagging_form) {
        Forms::TaggingForm.new(
          :purpose_uuid=>"ilc-al-libs-tagged-uuid",
          :parent_uuid=>"ilc-stock-plate-uuid",
          :tag_group_uuid=>"tag-group-uuid",
          :walking_by=>"manual by plate",
          :direction=>"column",
          :offset=>"0",
          :tag_start=>"1",
          :api       => api,
          :user_uuid => "user-uuid",
          :tag2_tube_barcode => "tag2-tube-barcode",
          :tag2_tube => { :asset_uuid => "tag-2-tube-uuid", :template_uuid => "tag-2-template-uuid" }
        )
      }

      # We retrieve the plate during initialization to set up the pools
      stub_request_and_response('ilc-stock-plate')
      # We retrieve the wells as part of this.
      stub_request_and_response('ilc-stock-plate-wells')

      it 'can be created' do
        expect(tagging_form).to be_a Forms::TaggingForm
      end

      it 'renders the "tagging" page' do
        controller = CreationController.new
        expect(controller).to receive(:render).with('tagging')
        tagging_form.render(controller)
      end

      context 'on save!' do
        # Create the al-libs-tagged plate
        stub_request_and_response('plate-creation-ilc-al-libs-tagged')
        # Fetch the custom transfer template
        stub_request_and_response('custom-plate-transfer-template')
        # Then create a new transfer using it
        stub_request_and_response('custom-plate-transfer-to-ilc-al-libs-tagged')
        # Apply the tag-group to the whole plate with no offset, starting at 1.
        stub_request_and_response('tag-layout-creation-a')

        # Then do the tag 2 specific stuff

        # Flags the tag 2 tube as exhausted
        stub_request_and_response('state-change-tag-2-tube-to-exhausted')
        # Retrieves tag 2 template
        stub_request_and_response('tag-2-template-uuid')
        # Applies the tag 2 template
        stub_request_and_response('tag-2-template-layout-creation-a')

        it 'creates a tag plate' do
          tagging_form.save!
        end

        it 'has the correct child (and uuid)' do
          tagging_form.save!
          expect(tagging_form.child.uuid).to eq('ilc-al-libs-tagged-plate-uuid')
        end
      end
    end
  end
end
