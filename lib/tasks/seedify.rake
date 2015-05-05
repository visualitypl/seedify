require 'seedify'

seed_list = Seedify::Storage.seed_list

if seed_list.include?('ApplicationSeed')
  desc 'Call the Application seed'
  task seedify: :environment do
    ApplicationSeed.call(task: true)
  end
end

namespace :seedify do
  seed_list.each do |seed|
    next if seed == 'ApplicationSeed'

    desc "Call the #{seed.underscore.humanize}"
    task seed.underscore.gsub('/', ':').sub(/_seed$/, '').sub(/:base$/, '') => :environment do
      seed.constantize.call(task: true)
    end
  end
end
