class PolymorphicNewsItems < ActiveRecord::Migration

  def self.up
    add_column :news_items, :itemable_id, :integer
    add_column :news_items, :itemable_type, :string, {:limit => 50}
    #
    add_index :news_items, :itemable_id
    #migrate old fks to polymorphic columns
    sql = ActiveRecord::Base.connection();
    sql.update "update news_items set itemable_id = news_topic_id, itemable_type = 'NewsTopic' where news_topic_id is not null"
    sql.update "update news_items set itemable_id = club_id, itemable_type = 'Club' where club_id is not null"
    #drop old fk columns
    #
    remove_column :news_items, :news_topic_id
    remove_column :news_items, :club_id
  end

  def self.down
    add_column :news_items, :news_topic_id, :integer
    add_column :news_items, :club_id, :integer
    #
    add_index :itemable, :news_topic_id
    add_index :itemable, :club_id
    #
    #migrate from polymorphic columns
    sql = ActiveRecord::Base.connection();
    sql.update "update news_items set news_topic_id = itemable_id where itemable_type = 'NewsTopic'"
    sql.update "update news_items set club_id = itemable_id where itemable_type = 'Club'"
    #
    remove_column :news_items, :itemable_id
    remove_column :news_items, :itemable_type
  end

end
