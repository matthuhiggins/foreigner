### 1.6.1 ###

*   Fix Rails 4.1 deprecation warning caused by use ```ActiveRecord::Migrator.proper_table_name```. (Thanks @ffmike)

### 1.6.0 ###

*   Fix support for latest version of the ```activerecord-jdbc-adapter``` gem.

### 1.5.0 ###

*   Add `foreign_key_exists?(table_name, options)`, to mirror the new Rails 4.0 method, ```index_exists?```.

### 1.4.1 ###

*   Support `create_table` calls where no block is passed.

### 1.4.0 ###

*   Add support for creating foreign keys during `create_table`.
