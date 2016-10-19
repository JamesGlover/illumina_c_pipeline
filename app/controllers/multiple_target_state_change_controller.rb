class MultipleTargetStateChangeController < ApplicationController

  def create

    if params[:tubes]
      tubes_uuid = params[:tubes].keys
      tubes_uuid.each do |uuid|
        purpose_uuid = api.multiplexed_library_tube.find(uuid).purpose.uuid
        state_changer_for(purpose_uuid, uuid).move_to!("passed")
      end
      tubes_ean13_barcodes = params[:tubes].values
      redirect_to(search_path, :notice => "Labware: #{tubes_ean13_barcodes.join(", ")} have been changed to a state of Passed")
    else
      redirect_to(search_path, :notice => "Nothing to pass")
    end

    rescue StateChangers::StateChangeError => exception
    respond_to do |format|
      format.html { redirect_to(search_path, :alert=> exception.message) }
      format.csv
    end
  end

  def state_changer_for(purpose_uuid, labware_uuid)
    StateChangers.lookup_for(purpose_uuid).new(api, labware_uuid, current_user_uuid)
  end
  private :state_changer_for

end