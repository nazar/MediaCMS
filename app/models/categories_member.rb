class CategoriesMember < ActiveRecord::Base

  belongs_to :member, :polymorphic => true
  belongs_to :category

  #class methods

  #instance methods

  def member_type=(member_type)
    super(member_type.constantize.base_class.name)
  end

end
