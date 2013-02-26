class DzoneLinks < ActiveRecord::Migration
  def self.up
    #table name type
    rename_column(:links, :descrition, :description)
    #dzone type links system
    add_column(:links, :votes_up,       :integer, :default => 0)
    add_column(:links, :votes_down,     :integer, :default => 0)
    add_column(:links, :views,          :integer, :default => 0)
    add_column(:links, :visits,         :integer, :default => 0)
    add_column(:links, :comments_count, :integer, :default => 0)
    add_column(:links, :saved_count,    :integer, :default => 0)
    add_column(:links, :active,         :boolean, :default => true)
    add_column(:links, :user_id,        :integer)
    add_column(:links, :created_at,     :datetime)
    add_column(:links, :screen_shot,    :string,  :limit => 254)
    add_column(:links, :rank,           :integer)
    #
    add_index(:links, :user_id)
    #set defaults for existing links
    Link.update_all('votes_down = 0, votes_up = 0, views = 0, visits = 0, comments_count = 0, saved_count = 0, active = 1')
  end

  def self.down
    rename_column(:links, :description, :descrition)
    #dzone type links system
    remove_column(:links, :votes_up)
    remove_column(:links, :votes_down)
    remove_column(:links, :views)
    remove_column(:links, :visits)
    remove_column(:links, :comments_count)
    remove_column(:links, :saved_count)
    remove_column(:links, :user_id)
    remove_column(:links, :created_at)
    remove_column(:links, :active)
    remove_column(:links, :screen_shot)
    remove_column(:links, :rank)
  end
end
