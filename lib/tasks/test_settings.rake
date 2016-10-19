namespace :test_settings do
  task :generate do
    settings = {searches: {'Find something' => nil},
                transfer_templates: {'Transfer columns' => nil},
                purposes: {'purpose-uuid' => nil},
                printers: {'limit' => 5, 'default_count' => 2}}
    File.open(File.join(Rails.root, %w{config settings}, "test.yml"), "w") {|f| f.write(settings.to_yaml)}
  end
end