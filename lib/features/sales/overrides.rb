require_dependency 'society_activity_sector'
require_dependency 'customer'
require_dependency 'establishment'
require_dependency 'society_activity_sector'
require_dependency 'application_helper'

class Customer
  has_many :orders

  def terminated_orders
    orders = []
    self.orders.each { |o| orders << o if o.terminated? }
    orders
  end
end

class Establishment
  has_many :orders
end

class SocietyActivitySector
  has_and_belongs_to_many :order_types
end

module ApplicationHelper
  private
    #def current_menu # override the original current_menu method in ApplicationHelper
    #  step_menu = "#{controller.class.current_order_path}_orders" if controller.class.respond_to?("current_order_path")
    #  menu = step_menu || controller.controller_name
    #  Menu.find_by_name(menu) or raise "The controller '#{menu}' should have a menu with the same name"
    #end
    
    # permits to display only steps which are activated for the current order
    def display_menu_entry_with_sales_support(menu, li_options)
      return if menu.name and menu.name.start_with?("step_") and !@order.steps.collect{ |s| s.name }.include?(menu.name)
      display_menu_entry_without_sales_support(menu, li_options)
    end
    
    alias_method_chain :display_menu_entry, :sales_support
    
    def url_for_menu(menu) # override the original url_for_menu method in ApplicationHelper
      if menu.name
        path = "#{menu.name}_path"
        
        controller_name = "#{menu.name.camelize}Controller"
        # return if controller_name == "OrdersController"
        begin
          controller_class = controller_name.constantize
          if controller_name == "OrdersController"
            path = "order_path(@order)"
          elsif controller_class.respond_to?(:current_order_step) # so it is a controller with acts_as_step support
            path = "order_#{path}"
          end
        rescue NameError => e
          # do nothing if the controller doesn't exist, just stay the basic path pattern
        end
        
        if self.respond_to?(path)
          self.send(path)
        else
          url_for(:controller => menu.name)
        end
      else
        unless menu.content.nil?
          url_for(:controller => "contents", :action => "show", :id => menu.content.id)
        else
          ""
        end
      end
    end
end

require 'application'
require_dependency 'customers_controller'
require_dependency 'product_references_controller'

class CustomersController < ApplicationController
  after_filter :detect_request_for_order_creation, :only => :new
  after_filter :redirect_to_new_order, :only => :create
  
  def auto_complete_for_customer_name
    find_options = { :include => :establishments,
                     :conditions => [ "thirds.name like ? or establishments.name like ?", "%#{params[:customer][:name]}%", "%#{params[:customer][:name]}%"],
                     :order => "thirds.name ASC",
                     :limit => 15 }
    @items = Customer.find(:all, find_options)
    render :inline => "<%= custom_auto_complete_result(@items, 'name', params[:customer][:name]) %>"
  end
  
  private
    def detect_request_for_order_creation
      session[:request_for_order_creation] = params[:order_request] === "1" ? true : false
    end
    
    def redirect_to_new_order
      if @customer.errors.empty? and session[:request_for_order_creation]
        session[:request_for_order_creation] = nil
        erase_redirect_results
        redirect_to( new_order_path(:customer_id => @customer.id) )
      end
    end
end

class ProductReferencesController < ApplicationController
  
  def auto_complete_for_product_reference_reference
    @items = ProductReference.find(:all, :conditions => [ 'reference LIKE ? or name like ? or information like ? or description like ?', pattern = "%#{params[:product_reference][:reference]}%", pattern, pattern, pattern ])
    render :inline => "<%= custom_auto_complete_result(@items, 'reference name', params[:product_reference][:reference]) %>"
  end
  
end
