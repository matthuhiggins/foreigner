namespace :db do
  desc "Generate a foreign key migration based on model associations"
  task :generate_model_keys => :environment do
    migration = Foreigner::Migration::Generator.create_model_migration!
    migration[:warnings].each do |warning|
      $stderr.puts "WARNING: #{warning}"
    end
    if migration[:filename]
      puts "Generated #{migration[:filename]}"
    else
      puts "Nothing to do"
    end
  end
end
