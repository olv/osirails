require File.dirname(__FILE__) + '/../thirds_test'

class CustomerSolvencyTest < ActiveSupport::TestCase
  should_belong_to :payment_method
  
  should_journalize :identifier_method => :name
end
