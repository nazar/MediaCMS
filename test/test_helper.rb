ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'


class Test::Unit::TestCase

  include AuthenticatedTestHelper

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...

  def default_user_hash(options)
    {:login => 'test_user', :password => 'test_password', :password_confirmation => 'test_password',
     :email => 'test@email.com', :terms => 1}.merge(options)
  end

  def create_user(options={})
    plan = HostPlan.create(:name => 'Free', :description => 'A free account is required to gain interactive access. Once signed up you will be able to post to our forums and post comments on both our blogs and photos. Although a limited space is provided to upload your own photos, these cannot be sold and will be freely available to all our members.',
                  :disk_space => 20, :monthly_fee => 0, :default_plan => 1)
    #manually create user for testing
    params = default_user_hash(options)
    user = User.new(params)
    user.setup_new_user(params[:login], params[:password], params[:email])
    user.host_plan = plan
    user.active    = options[:active].nil? ? false : options[:active]
    user.activated = options[:activated].nil? ? false : options[:activated]
    user.save!
    user
  end

  def create_categories
    cat1 = Category.create(:name => 'cat1', :description => 'desc1')
    cat1.children.create(:name => 'cat2', :description => 'desc2')
  end

end
