class ForumsRewrite < ActiveRecord::Migration
  def self.up
    add_column(:forums, :last_posted, :datetime)
    add_column(:posts, :poster_ip, :string, :limit => 20)
    add_column(:posts, :title, :string, :limit => 200)
    #
    remove_column(:forums, :description_html)
    remove_column(:posts, :body_html)
  end

  def self.down
    remove_column(:forums, :last_posted)
    remove_column(:posts, :poster_ip)
    remove_column(:posts, :title)
    #
    add_column(:forums, :description_html, :text)
    add_column(:posts, :body_html, :text)
  end
end
