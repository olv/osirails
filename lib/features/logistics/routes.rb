ActionController::Routing::Routes.add_routes do |map|
  map.resources :commodities
  map.resources :consumables
  map.resources :commodity_categories
  map.resources :consumable_categories
  
  map.with_options :name_prefix => '', :conditions => { :method => :get } do |m|
    m.disable_commodity     'commodities/:id/disable',    :controller => 'commodities', :action     => 'disable'
    m.disable_consumable    'consumables/:id/disable',    :controller => 'consumables', :action     => 'disable'
    m.reactivate_commodity  'commodities/:id/reactivate', :controller => 'commodities', :action     => 'reactivate'
    m.reactivate_consumable 'consumables/:id/reactivate', :controller => 'consumables', :action     => 'reactivate'
    
    m.disable_commodity_category      'commodity_categories/:id/disable',     :controller => 'commodity_categories',  :action => 'disable'
    m.disable_consumable_category     'consumable_categories/:id/disable',    :controller => 'consumable_categories', :action => 'disable'
    m.reactivate_commodity_category   'commodity_categories/:id/reactivate',  :controller => 'commodity_categories',  :action => 'reactivate'
    m.reactivate_consumable_category  'consumable_categories/:id/reactivate', :controller => 'consumable_categories', :action => 'reactivate'
  end
  
  map.refresh_measure_commodity 'commodities/refresh_measure',  :controller => 'commodities', :action => 'refresh_measure'
  map.refresh_measure_consumable 'consumables/refresh_measure', :controller => 'consumables', :action => 'refresh_measure'
  
  map.commodities_manager 'commodities_manager', :controller => 'commodities_manager'
  map.consumables_manager 'consumables_manager', :controller => 'consumables_manager'
 
  map.resources :restockable_supplies
  
  map.resources :inventories
  
  map.resources :stock_inputs
  map.resources :stock_outputs
  map.refresh_suppliers_stock_input   'stock_inputs/refresh_infos',       :controller => 'stock_inputs',  :action => 'refresh_infos'
  map.refresh_suppliers_stock_input   'stock_inputs/refresh_suppliers',   :controller => 'stock_inputs',  :action => 'refresh_suppliers'
  map.refresh_suppliers_stock_output  'stock_outputs/refresh_suppliers',  :controller => 'stock_outputs', :action => 'refresh_suppliers'
  
  map.stock_manager 'stock_manager', :controller => 'stock_inputs' #default page for stock manager
  
  map.logistics 'logistics', :controller => 'commodities_manager' #default page for logistics
end

