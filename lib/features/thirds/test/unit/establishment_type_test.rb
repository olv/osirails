require File.dirname(__FILE__) + '/../thirds_test'

class EstablishmentTypeTest < ActiveSupport::TestCase
  should_journalize :identifier_method => :name
  
  context "An empty establishment type" do
    setup do
      @establishment_type = EstablishmentType.new
      @establishment_type.valid?
    end
    
    should "require presence of name" do
      assert @establishment_type.errors.invalid?(:name)
    end
  end
  
  context "A complete establishment type" do
    setup do
      @establishment_type = EstablishmentType.new(:name => "Name")
      @establishment_type.valid?
    end
    
    should "valid presence of name" do
      assert !@establishment_type.errors.invalid?(:name)
    end
    
    should "be saved successfully" do
      assert @establishment_type.save!
    end
  end
end
