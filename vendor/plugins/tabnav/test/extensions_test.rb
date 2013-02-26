require 'test/unit'
require 'init'

class ExtensionsTest < Test::Unit::TestCase
  
  def test_symbol_to_tabnav
    assert :sample.to_tabnav == SampleTabnav.instance   
  end
  
end
