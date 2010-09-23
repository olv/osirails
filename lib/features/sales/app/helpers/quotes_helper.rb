module QuotesHelper
  
  def display_quotes(order)
    quotes = order.quotes.reject(&:new_record?)
    if quotes.empty?
      content_tag(:p, "Aucun devis n'a été trouvé")
    else
      render :partial => 'quotes/quotes_list', :object => quotes #.actives
    end
  end
  
  def display_quote_action_buttons(order, quote)
    html = []
    html << display_quote_confirm_button(order, quote, '')
    html << display_quote_send_button(order, quote, '')
    html << display_quote_sign_button(order, quote, '')
    html << display_quote_order_form_button(order, quote, '')
    html << display_quote_cancel_button(order, quote, '')
    
    html << display_quote_preview_button(order, quote, '')
    html << display_quote_show_pdf_button(order, quote, '')
    html << display_quote_show_button(order, quote, '')
    html << display_quote_edit_button(order, quote, '')
    html << display_quote_delete_button(order, quote, '')
    html.compact.join("&nbsp;")
  end
  
  def display_quote_list_button(step, message = nil)
    return unless Quote.can_add?(current_user)
    text = "Voir les devis"
    message ||= " #{text}"
    link_to( image_tag( "list_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             send(step.original_step.path))
  end
  
  def display_quote_add_button(order, message = nil)
    return unless Quote.can_add?(current_user) and order.quotes.build.can_be_added?
    text = "Nouveau devis"
    message ||= " #{text}"
    link_to( image_tag( "add_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_order_commercial_step_quote_step_quote_path(order))
  end
  
  def display_quote_show_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and !quote.new_record?
    text = "Voir ce devis"
    message ||= " #{text}"
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_quote_step_quote_path(order, quote) )
  end
  
  def display_quote_preview_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and !quote.new_record? and !quote.can_be_downloaded?
    text = "Télécharger un aperçu de ce devis (PDF)"
    message ||= " #{text}"
    link_to( image_tag( "preview_16x16.gif",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_quote_step_quote_path(order, quote, :format => :pdf) )
  end
  
  def display_quote_show_pdf_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and quote.can_be_downloaded?
    text = "Télécharger ce devis (PDF)"
    message ||= " #{text}"
    link_to( image_tag( "mime_type_extensions/pdf_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_quote_step_quote_path(order, quote, :format => :pdf) )
  end
  
  def display_quote_edit_button(order, quote, message = nil)
    return unless Quote.can_edit?(current_user) and quote.can_be_edited?
    text = "Modifier ce devis"
    message ||= " #{text}"
    link_to( image_tag( "edit_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             edit_order_commercial_step_quote_step_quote_path(order, quote) )
  end
  
  def display_quote_delete_button(order, quote, message = nil)
    return unless Quote.can_delete?(current_user) and quote.can_be_deleted?
    text = "Supprimer ce devis"
    message ||= " #{text}"
    link_to( image_tag( "delete_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             order_commercial_step_quote_step_quote_path(order, quote), :method => :delete, :confirm => "Êtes vous sûr?")
  end
  
  def display_quote_confirm_button(order, quote, message = nil)
    return unless Quote.can_confirm?(current_user) and quote.can_be_confirmed?
    text = "Valider ce devis"
    message ||= " #{text}"
    link_to( image_tag( "confirm_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_commercial_step_quote_step_quote_confirm_path(order, quote),
             :confirm => "Êtes-vous sûr ?\nCeci aura pour effet de générer un numéro unique pour le devis et vous ne pourrez plus le modifier." )
  end
  
  def display_quote_cancel_button(order, quote, message = nil)
    return unless Quote.can_cancel?(current_user) and quote.can_be_cancelled?
    text = "Annuler ce devis"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_commercial_step_quote_step_quote_cancel_path(order, quote),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_quote_send_button(order, quote, message = nil)
    return unless Quote.can_send_to_customer?(current_user) and quote.can_be_sended?
    text = "Signaler l'envoi du devis au client"
    message ||= " #{text}"
    link_to( image_tag( "send_to_customer_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_commercial_step_quote_step_quote_send_form_path(order, quote) )
  end
  
  def display_quote_sign_button(order, quote, message = nil)
    return unless Quote.can_sign?(current_user) and quote.can_be_signed?        
    text = "Signaler la signature du devis par le client"
    message ||= " #{text}"
    link_to( image_tag( "sign_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_commercial_step_quote_step_quote_sign_form_path(order, quote) )
  end
  
  def display_quote_order_form_button(order, quote, message = nil)
    return unless Quote.can_view?(current_user) and quote.signed? and quote.order_form
    text = "Télécharger le \"#{quote.order_form_type.name.downcase}\""
    message ||= " #{text}"
    link_to( image_tag( "mime_type_extensions/pdf_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             order_commercial_step_quote_step_quote_order_form_path(order, quote) )
  end
  
  def display_add_free_quote_item_for(quote)
    button_to_function "Insérer une ligne de commentaire" do |page|
      page.insert_html :bottom, :quote_items_body, :partial => 'quote_items/quote_item',
                                                   :object  => quote.quote_items.build
      last_item = page[:quote_items_body].select('.free_quote_item').last.show.visual_effect :highlight
      
      page << "update_up_down_links($('quote_items_body'))"
      page << "initialize_autoresize_text_areas()"
    end
  end
  
  def status_text(quote)
    case quote.status
      when nil
        'Brouillon'
      when Quote::STATUS_CANCELLED
        'Annulé'
      when Quote::STATUS_CONFIRMED
        'Validé'
      when Quote::STATUS_SENDED
        'Envoyé'
      when Quote::STATUS_SIGNED
        'Signé'
    end
  end
  
  def display_remaining_days_for(quote)
    delay = Date.today - quote.validity_date.to_date
    if delay < 0
      return "<br />(J-#{delay * -1})"  
    elsif delay > 0
      return "<br />(J+#{delay })"
    elsif delay == 0
      return "<br />(Jours J)"
    end  
  end
  
  def set_tr_class_name_for(quote)
    actual_date = Time.now.to_datetime
    date_limite = quote.validity_date  ? quote.validity_date.to_datetime : 0
    middle_date = (quote.validity_delay && quote.validity_date) ? (date_limite - (quote.validity_delay / 2).days).to_datetime : 0
    
    return ""  if (!quote.validity_delay || !quote.validity_date) 
    return "low_priority"  if (actual_date <= middle_date) 
    return "medium_priority"  if ((actual_date > middle_date) && (actual_date < date_limite))
    return "high_priority"     if (actual_date >= date_limite)
  end
  
end
