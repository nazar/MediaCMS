class RenameRanksTable < ActiveRecord::Migration
  def self.up
    rename_table('user_ranks', 'ranks')
  end
  
  def self.down
    rename_table('ranks', 'user_ranks')
  end
end