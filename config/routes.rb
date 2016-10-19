IlluminaCPipeline::Application.routes.draw do

  scope 'search', :controller => :search do
    match '/',                 :action => :new,            :via => :get,  :as => :search
    match '/',                 :action => :create_or_find, :via => :post, :as => :perform_search
    match '/ongoing_plates',   :action => :ongoing_plates
    match '/all_stock_plates', :action => :stock_plates
    match '/retrieve_parent',  :action => :retrieve_parent
    match '/qcables',          :action => :qcables,        :via => :post
  end

  resources :illumina_c_plates, :controller => :plates do
    resources :children, :controller => :plate_creation
    resources :tubes,    :controller => :tube_creation
    resources :qc_files, :controller => :qc_files
    resources :comments, :controller => :comments, :only => [:create]
  end

  post '/fail_wells/:id', :controller => :plates, :action => 'fail_wells', :as => :fail_wells

  namespace "admin" do
    resources :illumina_c_plates, :only => [:update, :edit], :as => :plates
  end

  resources :illumina_c_multiplexed_library_tube, :controller => :tubes do
    resources :qc_files, :controller => :qc_files
  end

  # This is a hack untill I get tube coercion working
  resources :illumina_c_tube, :controller => :tubes do
    resources :qc_files, :controller => :qc_files
  end

  resources :tag_plates, only: :show

  resources  :multiple_target_state_change, only: :create

  # This is a hack untill I get tube coercion working
  resources :sequencescape_tubes, :controller => :tubes do
    resources :qc_files, :controller => :qc_files
  end

  # Printing can do individual or multiple labels
  scope 'print', :controller => :barcode_labels, :via => :post do
    match 'individual', :action => 'individual', :as => :print_individual_label
    match 'multiple',   :action => 'multiple',   :as => :print_multiple_labels
  end

  root :to => "search#new"
end
