module Seedify
  class Railtie < Rails::Railtie
    railtie_name :seedify

    initializer 'seedify.autoload', before: :set_autoload_paths do |app|
      app.config.autoload_paths << Seedify::Storage.seed_directory
    end

    rake_tasks do
      load 'tasks/seedify.rake'
    end
  end
end
