class Third < ActiveRecord::Base
  has_one :address, :as => :has_address
  
  belongs_to :activity_sector
  belongs_to :third_type
  belongs_to :legal_form
  
  # has_many_polymorphic
  has_many :contacts_owners, :as => :has_contact
  has_many :contacts, :source => :contact, :through => :contacts_owners
  
  validates_presence_of :name
  validates_presence_of :legal_form
  validates_presence_of :siret_number
  validates_presence_of :activity_sector
  validates_format_of :siret_number, :with => /^[0-9]{14}/, :allow_blank => true #even if its presence is required, to avoid double error message #, :message => "doit comporter 14 chiffres"
  
  after_update :save_contacts
  
  RATINGS = { "0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5 }
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  @@form_labels[:legal_form] = "Forme juridique :"
  @@form_labels[:siret_number] = "Numéro SIRET :"
  @@form_labels[:activity_sector] = "Secteur d'activit&eacute; :"
  @@form_labels[:activities] = "Activités :"
  @@form_labels[:note] = "Note :"
  @@form_labels[:payment_method] = "Moyen de paiement préféré :"
  @@form_labels[:payment_time_limit] = "Délai de paiement préféré :"
  
  
  def contact_attributes=(contact_attributes)
    contact_attributes.each do |attributes|
      if attributes[:id].blank?
        contacts.build(attributes)
      else
        contact = contacts.detect { |t| t.id == attributes[:id].to_i }
        contact.attributes = attributes
      end
    end
  end
  
  def save_contacts
    contacts.each do |c|
      if c.should_destroy?
        contacts.delete(c) # delete the contact from the customer contacts' list, but dont delete the contact itself
      elsif c.should_update?
        c.save(false)
      end
    end
  end
end
