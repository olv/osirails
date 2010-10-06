class ParcelsController < ApplicationController

  helper :purchase_requests, :purchase_orders, :purchase_order_supplies, :parcel_items
  
  # GET /purchase_orders/:purchase_orders_id/parcels/new
  def new 
    @parcel = Parcel.new()
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  def create
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.new(params[:parcel])
    if @parcel.save
      flash[:notice] = "Le colis a été créé avec succès."
      redirect_to @purchase_order
    else
      render :action => "new"
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id
  def show
    @parcel = Parcel.find(params[:id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/alter_status
  def alter_status
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if params[:parcel][:status].to_i == Parcel::STATUS_PROCESSING_BY_SUPPLIER
      redirect_to purchase_order_parcel_process_by_supplier_form_path(@purchase_order, @parcel)
    elsif params[:parcel][:status].to_i == Parcel::STATUS_SHIPPED
      redirect_to purchase_order_parcel_ship_form_path(@purchase_order, @parcel)
    elsif params[:parcel][:status].to_i == Parcel::STATUS_RECEIVED_BY_FORWARDER
      redirect_to purchase_order_parcel_receive_by_forwarder_form_path(@purchase_order, @parcel)
    elsif params[:parcel][:status].to_i == Parcel::STATUS_RECEIVED
      redirect_to purchase_order_parcel_receive_form_path(@purchase_order, @parcel)
    elsif params[:parcel][:status].to_i == Parcel::STATUS_CANCELLED
      @parcel.canceller = current_user
      redirect_to purchase_order_parcel_cancel_form_path(@purchase_order, @parcel)
    else
      redirect_to purchase_order_path(@purchase_order)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/process_by_supplier_form
  def process_by_supplier_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.find(params[:parcel_id])
    error_access_page(412) unless @parcel.can_be_processed_by_supplier? 
    @parcel.status = Parcel::STATUS_PROCESSING_BY_SUPPLIER
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/process_by_supplier
  def process_by_supplier
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_processed_by_supplier?
      @parcel.attributes = params[:parcel]
      if @parcel.process_by_supplier
        flash[:notice] = "Le status du colis est bien passé à \"En traitement par le fournisseur\"."
        redirect_to @purchase_order
      else
        render :action => "process_by_supplier_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/ship_form
  def ship_form
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @parcel.can_be_shipped?
    @parcel.status = Parcel::STATUS_SHIPPED
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/ship
  def ship
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_shipped?
      @parcel.attributes = params[:parcel]
      if @parcel.ship
        flash[:notice] = "Le status du colis est bien passé à \"Expédié\"."
        redirect_to @purchase_order
      else
        render :action => "ship_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/receive_by_forwarder_form
  def receive_by_forwarder_form
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @parcel.can_be_received_by_forwarder?
    @parcel.status = Parcel::STATUS_RECEIVED_BY_FORWARDER
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end

  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/receive_by_forwarder  
  def receive_by_forwarder
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_received_by_forwarder?
      @parcel.attributes = params[:parcel]
      if @parcel.receive_by_forwarder
        flash[:notice] = "Le status du colis est bien passé à \"Reçu par le transitaire\"."
        redirect_to @purchase_order
      else
        render :action => "receive_by_forwarder_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/receive_form
  def receive_form
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @parcel.can_be_received?
    @parcel.status = Parcel::STATUS_RECEIVED
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end

  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/receive  
  def receive
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_received?
      @parcel.attributes = params[:parcel]
      if @parcel.receive
        flash[:notice] = "Le status du colis est bien passé à \"Reçu\"."
        redirect_to @purchase_order
      else
        render :action => "receive_form"   
      end
    else
      error_access_page(412)
    end
  end

  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/cancel_form
  def cancel_form
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    error_access_page(412) unless @parcel.can_be_cancelled?
    @parcel.status = Parcel::STATUS_CANCELLED
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/cancel
  def cancel
    @parcel = Parcel.find(params[:parcel_id])
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    if @parcel.can_be_cancelled?
      @parcel.attributes = params[:parcel]
      @parcel.canceller = current_user
      if @parcel.cancel
        flash[:notice] = "Le colis a été annulé avec succès."
        redirect_to @purchase_order
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end

  # GET /parcel_status_partial?status=:status 
  def parcel_status_partial
    render :partial => 'parcels/receive_forms' if params[:status].to_i == Parcel::STATUS_RECEIVED
    render :partial => 'parcels/ship_forms' if params[:status].to_i == Parcel::STATUS_SHIPPED
    render :partial => 'parcels/receive_by_forwarder_forms' if params[:status].to_i == Parcel::STATUS_RECEIVED_BY_FORWARDER
    render :partial => 'parcels/process_by_supplier_forms' if params[:status].to_i == Parcel::STATUS_PROCESSING_BY_SUPPLIER
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/attached_delivery_document
  def attached_delivery_document
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.find(params[:parcel_id])
    delivery_document =  @parcel.delivery_document
    url = delivery_document.purchase_document.path
   
    send_data File.read(url), :filename => "parcel_delivery.#{delivery_document.id}_#{delivery_document.purchase_document_file_name}", :type => delivery_document.purchase_document_content_type, :disposition => 'parcel_delivery'
  end 
  
end