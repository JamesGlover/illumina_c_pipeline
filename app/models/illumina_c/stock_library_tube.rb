class IlluminaC::StockLibraryTube < Sequencescape::MultiplexedLibraryTube

  def can_be_passed?
    ["pending", "started"].include? state
  end

end
