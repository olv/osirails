require File.dirname(__FILE__) + '/../rh_test'

class CivilityTest < ActiveSupport::TestCase
  should_journalize :identifier_method => :name
  
  def setup
    @civility = civilities(:mister)
  end

  def test_presence_of_name
    assert_no_difference 'Civility.count' do
      civility = Civility.create
      assert_not_nil civility.errors.on(:name), "A Civility should have a name"
    end
  end

  def test_uniqness_of_name
    assert_no_difference 'Civility.count' do
      civility = Civility.create(:name => @civility.name)
      assert_not_nil civility.errors.on(:name), "A Civility should have an uniq name"
    end
  end
end
