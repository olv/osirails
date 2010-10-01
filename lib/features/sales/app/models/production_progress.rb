class ProductionProgress < ActiveRecord::Base

  belongs_to :product
  belongs_to :production_step
  
  validates_numericality_of :progression, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100
  validates_numericality_of :building_quantity, :if => :building_quantity
  validates_numericality_of :built_quantity, :if => :built_quantity
  validates_numericality_of :available_to_deliver_quantity, :if => :available_to_deliver_quantity
  
  validate :validates_building_quantity, :validates_built_quantity, :validates_available_quantity 
  validate :validates_progression
  
  def validates_progression
    self.errors.add(:progression, I18n.t("activerecord.errors.models.production_progress.attributes.progression.inclusion", :restriction => "produit termin&eacute;")) if (self.progression.to_i == 100 && (self.built_quantity.to_i != self.product.quantity.to_i))
    self.errors.add(:progression, I18n.t("activerecord.errors.models.production_progress.attributes.progression.inclusion", :restriction => "produit livrables")) if (self.progression.to_i == 100 && (self.available_to_deliver_quantity.to_i != self.product.quantity.to_i))
  end
  
  def validates_building_quantity
    self.errors.add(:building_quantity, I18n.t("activerecord.errors.models.production_progress.attributes.building_quantity.inclusion", :restriction => "#{product.quantity.to_i  - self.built_quantity.to_i}")) unless (self.building_quantity.to_i >= 0 && self.building_quantity.to_i <= (product.quantity.to_i - self.built_quantity.to_i))
  end
  
  def validates_built_quantity
    self.errors.add(:built_quantity, I18n.t("activerecord.errors.models.production_progress.attributes.built_quantity.inclusion", :restriction => "#{product.quantity.to_i - self.building_quantity.to_i}")) if ((self.building_quantity.to_i + self.built_quantity.to_i > product.quantity.to_i) || (self.building_quantity.to_i < 0))
  end
  
  def validates_available_quantity
    self.errors.add(:available_to_deliver_quantity, I18n.t("activerecord.errors.models.production_progress.attributes.available_to_deliver_quantity.inclusion", :restriction => "#{self.built_quantity.to_i}")) if ((self.available_to_deliver_quantity.to_i > self.built_quantity.to_i ) || (self.available_to_deliver_quantity.to_i < 0))
  end
  
  def range_of_building_quantity
    (0..self.product.quantity - self.built_quantity.to_i)
  end
  
  def range_of_built_quantity
    (0..(self.product.quantity - self.building_quantity.to_i))
  end
  
  def range_of_available_quantity
    (0..self.built_quantity.to_i)
  end
  
end