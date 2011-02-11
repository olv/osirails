require File.dirname(__FILE__) + '/../logistics_test'

class ConsumableTest < ActiveSupport::TestCase
  #TODO
  #has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  #has_reference   :symbols => [ :supply_type ], :prefix => :logistics
  
  should_act_as_watchable
  
  should_belong_to :supply_type
  
  context "A consumable" do
    setup do
      @supply = Consumable.new
      @supply_type_class = ConsumableType
    end
    teardown do
      @supply = nil
    end
    
    subject{ @supply }
    
    include SupplyTest
  end
end
