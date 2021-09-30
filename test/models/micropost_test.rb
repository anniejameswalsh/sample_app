require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    
    @micropost = Micropost.new
  end


  test "should be valid" do
    assert @micropost.valid?
  end



end
