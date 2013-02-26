require 'test/unit'
require 'tab'

class TabTest < Test::Unit::TestCase

  EXPECTED_INSTANCE_METHODS = %w{named name links_to link highlights_on highlights titled title}
  
  def setup
    @tab = Tabnav::Tab.new do 
      named 'test'
      links_to :controller => 'pippo', :action => 'pluto'
    end
  end
  
  def test_not_nil
    assert !:sample.to_tabnav.nil?
  end
  
  def test_initialize
    begin
      t = Tabnav::Tab.new  
      assert false, "should fail without a provided block"
    rescue 
      assert true 
    end
  end
  
  def test_sanity
    tab1 = Tabnav::Tab.new {named 'one'}
    assert !tab1.nil?
    assert 'one', tab1.name
    
    tab2 = Tabnav::Tab.new {named 'two'}
    assert !tab2.nil?
    assert 'two', tab1.name
    
    assert_not_same tab1,tab2
  end
    
  def test_presence_of_instance_methods
    EXPECTED_INSTANCE_METHODS.each do |instance_method|
      assert @tab.respond_to?(instance_method), "#{instance_method} is not defined in #{@tab.inspect} (#{@tab.class})" 
    end     
  end
  
  def test_named 
    assert_equal 'test', @tab.name
    
    @tab.named 'test2'
    assert_equal 'test2', @tab.name
  end
  
  def test_links_to 
    assert_equal({:controller => 'pippo', :action => 'pluto'}, @tab.link)
    
    @tab.links_to :controller => 'pluto'
    assert_equal({:controller => 'pluto'}, @tab.link)
  end
  
  def test_highlights_on
    tab = Tabnav::Tab.new {named 'empty tab'}
    
    assert_equal [], tab.highlights, 'should return an empty array'
    tab.highlights_on :action => 'my_action'
    tab.highlights_on :action => 'my_action2', :controller => 'my_controller'
    
    assert tab.highlights.kind_of?(Array)
    assert_equal 2, tab.highlights.size, '2 highlights were added so far'
    
    tab.highlights.each {|hl| assert hl.kind_of?(Hash)}
    
    # sanity check
    assert_equal 'my_action', tab.highlights[0][:action] 
  end
  
  def test_highlighted
    tab = Tabnav::Tab.new {links_to :controller =>'pippo'}
    
    #check that highlights on its own link
    assert tab.highlighted?(:controller => 'pippo'), 'should highlight'
    assert tab.highlighted?(:controller => 'pippo', :action => 'list'),'should highlight'
    
    assert !tab.highlighted?(:controller => 'pluto', :action => 'list'),'should NOT highlight'
  
    # add some other highlighting rules
    # and check again
    tab.highlights_on :controller => 'pluto'
    assert tab.highlighted?(:controller => 'pluto'), 'should highlight'
  
    tab.highlights_on :controller => 'granny', :action => 'oyster'
    assert tab.highlighted?(:controller => 'granny', :action => 'oyster'), 'should highlight'
    
    assert !tab.highlighted?(:controller => 'granny', :action => 'daddy'), 'should NOT highlight'
   
    # test with a param that's not a string
    # as params are all passed as strings
    tab = Tabnav::Tab.new {links_to :id => 2}
    assert tab.highlighted?(:id => '2'), 'should highlight'
   
  end
  
  def test_highlighted_on_highlights
    tab = Tabnav::Tab.new {links_to :controller =>'pippo' } 
    #  links_to(:controller =>'pippo)
    #end
    
    assert tab.highlighted?(:controller => 'pippo')
    assert tab.highlighted?(:controller => 'pippo', :action => 'list')
    
    assert !tab.highlighted?(:controller => 'pluto', :action => 'list')
  end
 
end