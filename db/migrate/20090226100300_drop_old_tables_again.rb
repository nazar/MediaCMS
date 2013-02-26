class DropOldTablesAgain < ActiveRecord::Migration
  def self.up
    drop_table :photographers        if ActiveRecord::Base.connection.table_exists?('photographers')
    drop_table :php_stats_cache      if ActiveRecord::Base.connection.table_exists?('php_stats_cache')
    drop_table :php_stats_clicks     if ActiveRecord::Base.connection.table_exists?('php_stats_clicks')
    drop_table :php_stats_config     if ActiveRecord::Base.connection.table_exists?('php_stats_config')
    drop_table :php_stats_counters   if ActiveRecord::Base.connection.table_exists?('php_stats_counters')
    drop_table :php_stats_daily      if ActiveRecord::Base.connection.table_exists?('php_stats_daily')
    drop_table :php_stats_details    if ActiveRecord::Base.connection.table_exists?('php_stats_details')
    drop_table :php_stats_domains    if ActiveRecord::Base.connection.table_exists?('php_stats_domains')
    drop_table :php_stats_downloads  if ActiveRecord::Base.connection.table_exists?('php_stats_downloads')
    drop_table :php_stats_hourly     if ActiveRecord::Base.connection.table_exists?('php_stats_hourly')
    drop_table :php_stats_ip         if ActiveRecord::Base.connection.table_exists?('php_stats_ip')
    drop_table :php_stats_langs      if ActiveRecord::Base.connection.table_exists?('php_stats_langs')
    drop_table :php_stats_pages      if ActiveRecord::Base.connection.table_exists?('php_stats_pages')
    drop_table :php_stats_query      if ActiveRecord::Base.connection.table_exists?('php_stats_query')
    drop_table :php_stats_referer    if ActiveRecord::Base.connection.table_exists?('php_stats_referer')
    drop_table :php_stats_systems    if ActiveRecord::Base.connection.table_exists?('php_stats_systems')
    drop_table :logged_exceptions    if ActiveRecord::Base.connection.table_exists?('logged_exceptions')
  end

  def self.down
  end
end
