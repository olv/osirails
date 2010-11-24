class Subcontractor < Third
  include SiretNumber
  
  has_permissions :as_business_object
  has_contacts # please dont put in third.rb because has_contacts defines some routes and needs to know this class name
  has_address :address
  has_number  :phone
  has_number  :fax
  
  has_one :iban, :as => :has_iban
  
  belongs_to :activity_sector_reference
  
  named_scope :actives, :conditions => { :activated => true }
  
  validates_presence_of :activity_sector_reference_id
  validates_presence_of :activity_sector_reference, :if => :activity_sector_reference_id
  
  validates_uniqueness_of :siret_number, :scope => :type, :allow_blank => true
  
  journalize :attributes        => [ :name, :legal_form_id, :company_created_at, :collaboration_started_at, :activated ],
             :subresources      => [ :contacts, :address, :phone, :fax, :iban ],
             :identifier_method => :name
  
  has_search_index :only_attributes    => [ :name, :siret_number, :website ],
                   :only_relationships => [ :legal_form, :iban, :contacts, :activity_sector_reference, :address, :phone, :fax ]
  
  after_save :save_iban
  
  def iban_attributes=(iban_attributes)
    if iban_attributes[:id].blank?
      self.iban = build_iban(iban_attributes)
    else
      self.iban.attributes = iban_attributes
    end
  end
  
  def save_iban
    iban.save if iban
  end
end
