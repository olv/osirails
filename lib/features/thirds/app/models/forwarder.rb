class Forwarder < Third
  include SiretNumber
  include SupplierBase
  include CustomerBase
  
  has_permissions :as_business_object
  
  has_many :departures
  has_many :forwarder_conveyances
  has_many :conveyances, :through => :forwarder_conveyances
  has_many :quotation_forwarders
#  has_many :quotations, :through => :quotation_forwarders, :class_name => "Forwarder", :foreign_key => "forwarder_id"
  
  validates_uniqueness_of :name, :scope => :type, :message => "Ce nom existe déjà."
  
  FORWARDER_PER_PAGE = 15
  
  validates_associated :forwarder_conveyances
  
  after_save :save_forwarder_conveyances, :destroy_unselected_forwarder_conveyances
  
  has_search_index :only_attributes    => [:name, :siret_number],
                   :only_relationships => [:legal_form, :iban],
                   :main_model         => true
  
  @@form_labels[:name]        = "Raison sociale :"
  @@form_labels[:departure]   = "Point de départ :"
  @@form_labels[:conveyance]  = "Moyen de transport :"
  
  attr_accessor :conveyances_ids
  
  def activated_conveyances
    conveyances.select(&:activated)
  end
  
  def forwarder_conveyances_attributes=(conveyances_attributes)
    @conveyances_ids = conveyances_ids = conveyances_attributes.collect{ |conveyance_attributes| conveyance_attributes[:forwarder_conveyance_ids].to_i }
    conveyances_ids.each do |conveyance_id|
      unless forwarder_conveyances.detect{ |forwarder_conveyance| conveyance_id == forwarder_conveyance.conveyance_id }
        self.forwarder_conveyances.build(:conveyance_id => conveyance_id, :forwarder_id => self.id)
      end
    end
  end
  
  def destroy_unselected_forwarder_conveyances
    @conveyances_ids ||= []
    self.forwarder_conveyances.each{|forwarder_conveyance| forwarder_conveyance.destroy() unless @conveyances_ids.detect{|conveyance_id| conveyance_id == forwarder_conveyance.conveyance_id} }
  end
  
  def departure_attributes=(departures_attributes)
    departures_attributes.each do |attributes|
      self.departures.build(attributes)
    end
  end
  
#  def destroy_unselected_forwarder_departures
#    @departures_ids ||= []
#    self.forwarder_departures.each{ |forwarder_departure| forwarder_departure.destroy() unless @departures_ids.detect{|departure_id| departure_id == forwarder_departure.departure_id} }
#  end
  
  def save_forwarder_departures
#    self.forwarder_departures.each{ |forwarder_departure| forwarder_departure.save(false)}
  end
  
  def save_forwarder_conveyances
#    self.forwarder_conveyances.each{ |forwarder_conveyance| forwarder_conveyance.save(false)}
  end
  
  def can_be_destroyed?
#    quotations.empty?
    true
  end
  
end