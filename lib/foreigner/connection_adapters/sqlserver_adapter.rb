module Foreigner
  module ConnectionAdapters
    module SQLServerAdapter
      include Foreigner::ConnectionAdapters::Sql2003

      def foreign_keys(table_name)
        # Called from schema_dump
        fk_info = select_all %{
          SELECT  to_table.name AS to_table,
                  -- from_table.name AS from_table,
                  from_column.name AS from_column,
                  to_column.name AS primary_key,
                  foreign_key.name AS name,
		  OBJECTPROPERTY(foreign_key.id,'CnstIsUpdateCascade') as update_is_cascade,
		  OBJECTPROPERTY(foreign_key.id,'CnstIsDeleteCascade') as delete_is_cascade
          FROM    sysobjects AS from_table,
                  sysforeignkeys AS f,
                  sysobjects AS to_table,
                  sysobjects AS foreign_key,
                  syscolumns AS from_column,
                  syscolumns AS to_column
          WHERE   from_table.type = 'U'
            AND   from_table.id = f.fkeyid
            AND   f.constid = foreign_key.id
            AND   f.rkeyid = to_table.id
            AND   f.fkey = from_column.colid
            AND   from_column.id = from_table.id
            AND   f.rkey = to_column.colid
            AND   to_column.id = to_table.id
            AND   from_table.name = '#{table_name}'
          ORDER BY from_table.name, to_table.name, foreign_key.name, from_column.name
        }

        fk_info.map do |row|
          options = {:column => row['from_column'], :name => row['name'], :primary_key => row['primary_key']}

          options[:dependent] =
	    if row['delete_is_cascade']
	      if row['update_is_cascade']
		:cascade
	      else
		:delete
	      end
	    else
	      :restrict
	    end
	    # Don't know how to extract ON DELETE DEFAULT, ON DELETE SET NULL

          ForeignKeyDefinition.new(table_name, row['to_table'], options)
        end
      end
    end
  end
end

[:SQLServerAdapter, :JdbcAdapter].each do |adapter|
  begin
    ActiveRecord::ConnectionAdapters.const_get(adapter).class_eval do
      include Foreigner::ConnectionAdapters::SQLServerAdapter
    end
  rescue
  end
end
