module Seedify
  class Railtie < Rails::Railtie
    railtie_name :seedify

    rake_tasks do
      load 'tasks/seedify.rake'
    end
  end
end
