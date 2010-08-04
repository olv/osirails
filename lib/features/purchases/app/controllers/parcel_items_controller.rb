class ParcelItemsController < ApplicationController
  
  helper :purchase_requests, :purchase_orders, :purchase_order_supplies, :parcels
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/parcel_items/:parcel_item_id/cancel_form
  def cancel_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.find(params[:parcel_id])
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    unless @parcel_item.can_be_cancelled?
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/parcel_items/:parcel_item_id/cancel 
  def cancel
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.find(params[:parcel_id])
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    if @parcel_item.can_be_cancelled?
      @parcel_item.attributes = params[:parcel_item]
      @parcel_item.canceller = current_user
      if @parcel_item.cancel
        flash[:notice] = "Le contenu correspondant a été annulé."
        redirect_to( purchase_order_parcel_path(@parcel_item.purchase_order_supply.purchase_order, @parcel_item.parcel))
      else
        render :action => "cancel_form"   
      end
    else
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/parcel_items/:parcel_item_id/report_form
  def report_form
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.find(params[:parcel_id])
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    unless @parcel_item.can_be_reported?
      error_access_page(412)
    end
  end
  
  # GET /purchase_orders/:purchase_orders_id/parcels/:parcel_id/parcel_items/:parcel_item_id/report
  def report
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @parcel = Parcel.find(params[:parcel_id])
    @parcel_item = ParcelItem.find(params[:parcel_item_id])
    if @parcel_item.can_be_reported?
      @parcel_item.attributes = params[:parcel_item]
      if @parcel_item.report
        flash[:notice] = "Le contenu correspondant a été signalé comme défectueux."
        redirect_to( purchase_order_path(@parcel_item.purchase_order_supply.purchase_order))
      else
        render :action => "report_form"   
      end
    else
      error_access_page(412)
    end
  end
  
end