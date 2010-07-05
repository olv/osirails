class CommoditySubCategory < SupplySubCategory
  belongs_to :supply_category, :class_name => "CommodityCategory"
  
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :enable]
  has_reference   :symbols => [ :supply_category ], :prefix => :logistics
  
  has_many :supplies, :class_name => "Commodity", :foreign_key => :supply_sub_category_id
  
  validates_persistence_of :supply_category_id
  
  has_search_index  :only_attributes    => [ :reference, :name ],
                    :only_relationships => [ :supply_category, :supplies ]
end