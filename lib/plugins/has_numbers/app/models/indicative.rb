class Indicative < ActiveRecord::Base
  belongs_to :country
  
  validates_presence_of :indicative, :country_id
  validates_presence_of :country, :if => :country_id
  
  has_search_index :only_attributes => [:indicative]
end
 