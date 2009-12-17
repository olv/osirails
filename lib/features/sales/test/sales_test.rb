require 'lib/features/thirds/test/thirds_test'
require File.dirname(__FILE__) + '/unit/product_base_test'

class Test::Unit::TestCase
  
  def prepare_sales_processes
    OrderType.all.each do |order_type|
      Step.all.each do |step|
        order_type.sales_processes.create(:step_id => step.id, :activated => true, :depending_previous => false, :required => true)
      end
    end
  end
  
  def create_default_order
    prepare_sales_processes
    
    ## prepare customer
    customer = create_default_customer
    
    ## prepare society_activity_sector
    society_activity_sector = SocietyActivitySector.first
    society_activity_sector.order_types << OrderType.all
    
    order = Order.new(:title => "Titre", :customer_needs => "Customer Needs", :previsional_delivery => Time.now + 10.days)
    order.commercial = employees(:john_doe)
    order.creator = users(:powerful_user)
    order.customer = customer
    order.contacts = [ customer.contacts.first, customer.contacts.last ]
    order.society_activity_sector = society_activity_sector
    order.order_type = society_activity_sector.order_types.first
    order.build_bill_to_address(order.customer.bill_to_address.attributes)
    order.build_ship_to_address(order.customer.establishments.first)
    order.approaching = approachings(:email)
    flunk "Order should be saved > #{order.errors.full_messages.join(', ')}" unless order.save
    return order
  end
  
  def create_valid_product_for(order)
    product = order.products.build
    product.product_reference_id  = product_references(:product_reference1).id
    product.name                  = product_references(:product_reference1).name
    product.description           = "My description"
    product.dimensions            = "1000x500"
    product.quantity              = 3
    product.save!
    return product
  end
  
  def create_quote_for(order)
    x = 4 # number of products and quote_items
    x.times do
      create_valid_product_for(order)
    end
    
    quote = order.quotes.build(:validity_delay => 30, :validity_delay_unit => 'days')
    quote.creator = users(:powerful_user)
    quote.contacts << contacts(:pierre_paul_jacques)
    
    order.products.each do |product|
      quote.build_quote_item(:product_id  => product.id,
                             :order_id    => order.id,
                             :name        => "Product Name",
                             :description => "Product description",
                             :dimensions  => "1000x2000",
                             :quantity    => 2,
                             :unit_price  => 20000,
                             :discount    => 0.0,
                             :vat         => 19.6)
    end
    
    flunk "Quote should be created" unless quote.save
    flunk "Quote should have #{x} quote_items" unless quote.quote_items.count == x
    return quote
  end
  
  def create_signed_quote_for(order)
    quote = create_quote_for(order)
    flunk "Quote should be confirmed"           unless quote.confirm
    flunk "Quote should be sended to customer"  unless quote.send_to_customer(:sended_on            => Date.today,
                                                                              :send_quote_method_id => send_quote_methods(:mail).id)
    
    attachment = File.new(File.join(RAILS_ROOT, "test", "fixtures", "order_form.pdf"))
    flunk "Quote should be signed" unless quote.sign(:signed_on          => Date.today,
                                                     :order_form_type_id => order_form_types(:signed_quote).id,
                                                     :order_form         => attachment)
    return quote
  end
  
  def create_valid_delivery_note_for(order)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.delivery_notes.build
    dn.creator = users(:powerful_user)
    dn.ship_to_address = address
    dn.contacts = [ contacts(:pierre_paul_jacques) ]
    dn.associated_quote.quote_items.each do |ref|
      dn.delivery_note_items.build(:quote_item_id => ref.id,
                                   :quantity      => ref.quantity)
    end
    dn.save!
    
    flunk "order should have all its products delivered or scheduled" unless order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_partial_delivery_note_for(order)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    # prepare delivery note
    dn = order.delivery_notes.build
    dn.creator = users(:powerful_user)
    dn.ship_to_address = address
    dn.contacts = [ contacts(:pierre_paul_jacques) ]
    count = 0
    dn.associated_quote.quote_items.each do |ref|
      break if count == 2
      dn.delivery_note_items.build(:quote_item_id => ref.id,
                                   :quantity      => ref.quantity)
      count += 1
    end
    dn.save!
    
    flunk "order should NOT have all its products delivered or scheduled" if order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_complementary_delivery_note_for(order)
    address = Address.create( :street_name       => "Street Name",
                              :country_name      => "Country",
                              :city_name         => "City",
                              :zip_code          => "01234",
                              :has_address_type  => "DeliveryNote",
                              :has_address_key   => "ship_to_address" )
    
    dn = order.build_delivery_note_with_remaining_products_to_deliver
    dn.creator = users(:powerful_user)
    dn.ship_to_address = address
    dn.contacts = [ contacts(:pierre_paul_jacques) ]
    dn.save!
    
    flunk "order should have all its products delivered or scheduled" unless order.all_is_delivered_or_scheduled?
    return dn
  end
  
  def create_valid_intervention_for(delivery_note)
    flunk "delivery_note should NOT have interventions to continue > #{delivery_note.interventions.inspect}" unless delivery_note.interventions.empty?
    flunk "delivery_note should be validated to continue" if !delivery_note.validated? and !delivery_note.validate_delivery_note
    
    intervention = delivery_note.interventions.build(:on_site => true,
                                                     :scheduled_delivery_at => Time.now + 10.hours)
    intervention.deliverers << Employee.first
    
    intervention.save!
    return intervention
  end
  
  def create_valid_discard_for(delivery_note)
    intervention = create_valid_intervention_for(delivery_note)
    intervention.delivered = true
    intervention.comments = "my special comment"
    
    flunk "delivery_note should be valid to perform the following" unless delivery_note.valid?
    
    reference = delivery_note.delivery_note_items.first
    discard = reference.build_discard(:comments => "my special comment",
                                      :quantity => reference.quantity,
                                      :discard_type_id => discard_types(:low_quality).id)
    
    flunk "delivery_note should be saved > #{delivery_note.errors.full_messages.join(', ')}" unless delivery_note.save
    return discard
  end
  
  def sign_delivery_note(delivery_note)
    intervention = create_valid_intervention_for(delivery_note)
    intervention.delivered = true
    intervention.comments = "my comments"
    delivery_note.signed_on = Date.today + 6.days
    delivery_note.attachment = File.new(File.join(RAILS_ROOT, "test", "fixtures", "delivery_note_attachment.pdf"))
    
    flunk "delivery_note should be signed to continue" unless delivery_note.sign_delivery_note
    return delivery_note
  end
  
  def create_signed_delivery_note_for(order)
    delivery_note = create_valid_delivery_note_for(order)
    delivery_note = sign_delivery_note(delivery_note)
    return delivery_note
  end
  
  def create_signed_partial_delivery_note_for(order)
    delivery_note = create_valid_partial_delivery_note_for(order)
    delivery_note = sign_delivery_note(delivery_note)
    return delivery_note
  end
  
  def create_signed_complementary_delivery_note_for(order)
    delivery_note = create_valid_complementary_delivery_note_for(order)
    delivery_note = sign_delivery_note(delivery_note)
    return delivery_note
  end
end
