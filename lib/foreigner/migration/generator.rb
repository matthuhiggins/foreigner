module Foreigner
  module Migration
    module Generator
      class << self
        attr_writer :migration_path, :model_path
        def migration_path
          @migration_path ||= File.join(Rails.root, "db", "migrate")
        end
        def model_path
          @model_path ||= File.join(Rails.root, "app", "models")
        end

        def create_model_migration!
          migration_info = {}
          add_statements = []
          remove_statements = []
          new_keys, warnings = new_model_keys
          if new_keys.present?
            new_keys.each do |foreign_key|
              add_statements << add_foreign_key_statement(foreign_key)
              remove_statements << "remove_foreign_key #{foreign_key.from_table.inspect}, :name => #{foreign_key.options[:name].inspect}"
            end
  
            migration_info = generate_migration_info
            write_migration(migration_info[:filename], migration_info[:name], add_statements, remove_statements)
          end
          {:filename => migration_info[:filename], :warnings => warnings}
        end

        def new_model_keys(db_keys = current_foreign_keys, classes = model_classes)
          database_keys = db_keys.inject({}) { |hash, foreign_key|
            hash[foreign_key.hash_key] = foreign_key
            hash
          }
          model_keys, warnings = model_keys(classes)
          new_keys = []
          model_keys.keys.each do |hash_key|
            foreign_key = model_keys[hash_key]
            # if the foreign key exists in the db, we call it good (even if
            # the name is different or :dependent doesn't match), though 
            # we do warn on clearly broken stuff
            if current_key = database_keys[hash_key]
              if current_key.to_table != foreign_key.to_table || current_key.options[:primary_key] != foreign_key.options[:primary_key]
                warnings[hash_key] = "Skipping #{foreign_key.from_table}.#{foreign_key.options[:column]}: its association references a different key/table than its current foreign key"
              end
            else
              new_keys << foreign_key
            end
          end
          [new_keys.sort_by{ |key| key.options[:name] }, warnings]
        end

        def add_foreign_key_statement(foreign_key)
          statement_parts = [ ('add_foreign_key ' + foreign_key.from_table.inspect) ]
          statement_parts << foreign_key.to_table.inspect
          statement_parts << (':name => ' + foreign_key.options[:name].inspect)

          if foreign_key.options[:column] != "#{foreign_key.to_table.singularize}_id"
            statement_parts << (':column => ' + foreign_key.options[:column].inspect)
          end
          if foreign_key.options[:primary_key] != 'id'
            statement_parts << (':primary_key => ' + foreign_key.options[:primary_key].inspect)
          end
          if foreign_key.options[:dependent].present?
            statement_parts << (':dependent => ' + foreign_key.options[:dependent].inspect)
          end
          statement_parts.join(', ')
        end

      private
        def current_foreign_keys
          ActiveRecord::Base.connection.tables.map{ |table|
            ActiveRecord::Base.connection.foreign_keys(table)
          }.flatten
        end

        def write_migration(filename, name, up_statements, down_statements)
          File.open(filename, "w"){ |f| f.write <<-MIGRATION }
# This migration was auto-generated via `rake db:generate_model_keys'.

class #{name} < ActiveRecord::Migration
  def self.up
    #{up_statements.sort.join("\n    ")}
  end

  def self.down
    #{down_statements.sort.join("\n    ")}
  end
end
          MIGRATION
        end

        def generate_migration_info
          migration_names = Dir.glob(File.join(migration_path, '*.rb')).map{ |f| f.gsub(/.*\/\d+_(.*)\.rb/, '\1')}
          migration_base_name = "association_foreign_keys"
          name_version = nil
          while migration_names.include?("#{migration_base_name}#{name_version}")
            name_version = name_version.to_i + 1
          end
          migration_name = "#{migration_base_name}#{name_version}"

          migration_version = ActiveRecord::Base.timestamped_migrations ?
            Time.now.getutc.strftime("%Y%m%d%H%M%S") :
            Dir.glob(File.join(migration_path, '*.rb')).map{ |f| f.gsub(/.*\/(\d+)_.*/, '\1').to_i}.inject(0){ |curr, i| i > curr ? i : curr } + 1
          filename = File.join(migration_path, "#{migration_version}_#{migration_name.underscore}.rb")
          {:name => migration_name.camelize, :filename => filename}
        end

        def model_classes
          classes = []
          Dir[model_path + '/*.rb'].each do |model|
            class_name = model.sub(/\A.*\/(.*?)\.rb\z/, '\1').camelize
            begin
              klass = class_name.constantize
            rescue SyntaxError, LoadError
              raise "unable to load #{class_name} and its associations" if File.read(model) =~ /^\s*(has_one|has_many|has_and_belongs_to_many|belongs_to)\s/
              next
            end
            classes << klass if klass < ActiveRecord::Base
          end
          classes
        end

        def model_keys(classes)
          # see what the models say there should be
          foreign_keys = {}
          warnings = {}
          classes.map{ |klass|
            foreign_keys_for(klass)
          }.flatten.uniq.each do |foreign_key|
            # we may have inferred it from several places (e.g. "Bar.belongs_to :foo",
            # "Foo.has_many :bars", and "Foo.has_many :bazzes, :class_name => Bar")...
            # we need to make sure everything is legit and see if any of them specify
            # :dependent => :delete
            if current_key = foreign_keys[foreign_key.hash_key]
              if current_key.to_table != foreign_key.to_table || current_key.options[:primary_key] != foreign_key.options[:primary_key]
                warnings[foreign_key.hash_key] ||= "Skipping #{foreign_key.from_table}.#{foreign_key.options[:column]}: it has multiple associations referencing different keys/tables."
                next
              else
                next unless foreign_key.options[:dependent]
              end
            end
            foreign_keys[foreign_key.hash_key] = foreign_key
          end
          warnings.keys.each { |hash_key| foreign_keys.delete(hash_key) }
          [foreign_keys, warnings]
        end

        def foreign_keys_for(klass)
          klass.reflections.values.reject{ |reflection|
            # some associations can just be ignored, since:
            # 1. we aren't going to parse SQL
            # 2. foreign keys for :through associations will be handled by their component has_one/has_many/belongs_to associations
            # 3. :polymorphic(/:as) associations can't have foreign keys
            (reflection.options.keys & [:finder_sql, :through, :polymorphic, :as]).present?
          }.map{ |reflection|
            case reflection.macro
              when :belongs_to
                Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
                  klass.table_name, reflection.klass.table_name,
                  :column => reflection.primary_key_name,
                  :primary_key => reflection.klass.primary_key,
                  # although belongs_to can specify :dependent, it doesn't make
                  # sense from a foreign key perspective
                  :dependent => nil
                )
              when :has_one, :has_many
                Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
                  reflection.klass.table_name, klass.table_name,
                  :column => reflection.primary_key_name,
                  :primary_key => klass.primary_key,
                  :dependent => [:delete, :delete_all].include?(reflection.options[:dependent]) && reflection.options[:conditions].nil? ? :delete : nil
                )
              when :has_and_belongs_to_many
                [
                  Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
                    reflection.options[:join_table], klass.table_name,
                    :column => reflection.primary_key_name,
                    :primary_key => klass.primary_key,
                    :dependent => nil
                  ),
                  Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
                    reflection.options[:join_table], reflection.klass.table_name,
                    :column => reflection.association_foreign_key,
                    :primary_key => reflection.klass.primary_key,
                    :dependent => nil
                  )
                ]
            end
          }.flatten
        end
			end
    end
  end
end