# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def file_upload
    file_field 'upload', 'datafile'
  end
  
  def display_flash
    html = ""
    flash.each_pair do |key, value|
      html << '<br/>' unless html == ""
      html << "<span class=\"flash_#{key}\"><span>#{value}</span></span>"
    end
    html.empty? ? "" : "<div class=\"flash_container\">" << html << "</div>"
  end
  
  def current_user
    begin
      User.find(session[:user_id])
    rescue
      return false
    end
  end
  
  def display_menu
    menu = current_menu
    html = ""
    html << display_menu_entries(menu)
    html
  end
  
  #TODO remove that for good!
  def display_memorandums
    ""
  end
  
  def display_welcome_message
    "Bienvenue, " + current_user.username
  end
  
  def display_date_time
    day = DateTime.now.strftime("%A").downcase
    DateTime.now.strftime("Nous sommes le #{day} %d %B %Y, il est %H:%M")
  end
  
  def display_footer
    society_name  = content_tag :span, ConfigurationManager.admin_society_identity_configuration_name
    siret         = content_tag :span, ConfigurationManager.admin_society_identity_configuration_siret
    address       = content_tag :span, "#{ConfigurationManager.admin_society_identity_configuration_address_first_line} - \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_second_line} - \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_zip} \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_town} - \
                                        #{ConfigurationManager.admin_society_identity_configuration_address_country}"
    phone         = content_tag :span, ConfigurationManager.admin_society_identity_configuration_phone
    fax           = content_tag :span, ConfigurationManager.admin_society_identity_configuration_fax
    "#{society_name} SIRET : #{siret} TEL : #{phone} FAX : #{fax} <br/> ADRESSE : #{address}"
  end
  
  def contextual_search()
    html= "<p>"
    
    model_for_search = controller.controller_name.singularize.camelize
    
    html+= "<input type='hidden' name=\"contextual_search[model]\" value='#{model_for_search}' />"
    html+= text_field_tag "contextual_search[value]",'Rechercher',:id => 'input_search',:onfocus=>"if(this.value=='Rechercher'){this.value='';}", :onblur=>"if(this.value==\"\"){this.value='Rechercher';}", :style=>"color:grey;"
    html+= "<button type=\"submit\" class=\"contextual_search_button\"></button>"
    html+= link_to( "Recherche avancée", search_path(:choosen_model => model_for_search), :class => 'help')
    html+="</p>"
  end
  
  # This method permit to point out if a required local variable hasn't been passed (or with a nil object) with the 'render :partial' call
  # 
  # Example 1 :
  # in edit.html.erb
  # <%= render :partial => @user %>
  # 
  # in _user.html.erb
  # <% require_locals my_missing_local %> # => raise an error
  # 
  # Example 2 :
  # in new.html.erb
  # <%= render :partial => @user, :locals => { :my_local => my_local } %>
  # 
  # in _user.html.erb
  # <% require_locals my_local %> # => no error
  # 
  # 
  # The method accepts many variable at time :
  # <% require_locals local1, local2, local3 %>
  #
  def require_locals *locals
    locals.each do |local|
      raise "The partial you called requires at least one local variable. Please verify if the(se) local(s) is/are correctly referenced when you call your render :partial" if local.nil?
    end
  end
  
  # Returns - true if the current page is an editable page (add/edit)
  #         - false if the current page is an view page (show)
  #
  def is_form_view?
     is_edit_view? or is_new_view?
  end
  
  def is_new_view?
    params[:action] == "new" or request.post?
  end
  
  def is_edit_view?
    params[:action] == "edit" or request.put?
  end
  
#  def can_edit?(object)
#    test_permission("edit", object)
#  end
#  
#  def can_add?(object)
#    test_permission("add", object)
#  end
  
  begin
    ## dynamic methods generated with the menus object
    #  
    #  Example :
    #  menus :             users, groups, thirds
    #  generated methods : menu_users, menu_groups, menu_thirds
    Menu.find(:all, :conditions => [ "name IS NOT NULL" ]).each do |menu|
      define_method("menu_#{menu.name}") do
        Menu.find_by_name(menu.name)
      end
    end
  rescue ActiveRecord::StatementInvalid, Mysql::Error => e
    error = "An error has occured in file '#{__FILE__}'. Please restart the server so that the application works properly. (error : #{e.message})"
    RAKE_TASK ? puts(error) : raise(error)
  end
  
  def contextual_menu(title, &block)
    raise ArgumentError, "Missing block" unless block_given?
    
    at_least_one_line = false
    html = content_tag(:h1, title)
    html += "<ul>"
    capture(&block).split("\n").each do |line|
      next if line.blank?
      at_least_one_line = true
      html += content_tag :li, line
    end
    html += "</ul>"
    return content_for(:contextual_menu) {html} if at_least_one_line
  end

  private
    # Creates dynamic helpers to generate standard links in all page
    # These dynamic helpers are based on RESTful path methods generated from routes
    # 
    # Methods must start end by "_link"
    # 
    # ==== Examples
    #   users_link                          # model => user        | action => list   | method called => users_path
    #   new_group_link                      # model => group       | action => add    | method called => new_group_path
    #   user_link(@user)                    # model => user        | action => view   | method called => user_path(@user)
    #   edit_user_link(@user)               # model => user        | action => edit   | method called => edit_user(@user)
    #   delete_geat_model_link(@geat_model) # model => geat_model  | action => delete | method called => link_to("Delete", @user, { :method => :delete, :confirm => "Are you sure?"})
	  #
	  # ==== Arguments
	  # For the actions +list+ and +add+, only one parameter is allowed
	  # 
	  # For the actions +view+, +edit+, +delete+, the first parameter (+object+) is required, and a second parameter is allowed
	  # 
	  # The first parameter (for +list+ and +add+) and the second parameter (for +view+, +edit+ and +delete+) must be a Hash
	  # 
	  # <tt>:image_tag</tt> permits to define a custom image tag for the link
    #   <%= user_link(@user, :image_tag => image_tag("/images/view.png") ) %>
    # 
    # <tt>:link_text</tt> permits to define a custom value for the link label
    #   <%= new_user_link( :link_text => "Add a user" ) %>
    # 
    def method_missing(method, *args)
      # did somebody tried to use a dynamic link helper?
      super(method, *args) unless method.to_s.match(/_link$/)
      
      # retrieve objects and options hash into args array
			args_objects = []
      options = {}
			args.each do |arg|
			  if arg.is_a?(Hash)
  				options.merge!(arg)
				elsif arg.class.ancestors.include?(ActiveRecord::Base)
          args_objects << arg
        else
          raise ArgumentError, "#{method} expected 'hash' or 'ActiveRecord object' parameter but received #{arg}:#{arg.class}"
        end
			end
      
      # retrieve infos about model and path from the given method
      method_infos              = dynamic_link_catcher_retrieve_method_infos(method.to_s, args_objects)
      path_name                 = method_infos[:path_name]
      model_name                = method_infos[:model_name]
      expected_objects          = method_infos[:expected_objects]
      
      # check if the method called is well-formed
      dynamic_link_catcher_check_arguments_objects(expected_objects, args_objects)

      # define what is the permission method name according to the given method
      if model_name != model_name.singularize       # users
        permission_name = :list
        model_name = model_name.singularize
      
      elsif path_name.match(/^(formatted_)?new_/)   # new_user    | formatted_new_user
        permission_name = :add
      
      elsif path_name.match(/^(formatted_)?edit_/)  # edit_user   | formatted_edit_user
        permission_name = :edit
      
      elsif path_name.match(/^delete_/)             # delete_user
        permission_name = :delete
        path_name = path_name.gsub("delete_","")    # the prefix "delete_" is removed because it doesn't match to any path method name
  
      elsif path_name.match(/^(formatted_)?/)       # user       | formatted_user  | great_model |  formatted_great_model
        permission_name = :view
      
      else
        raise NameError, "'#{method}' seems to be a dynamic helper link, but it has an unexpected form. Maybe you misspelled it? "
      end
      
      # define the corresponding model, and check the permissions
      model                     = model_name.camelize.constantize # this will raise a NameError Exception if the constant is not defined
		  has_model_permission      = model.respond_to?("business_object?") ? model.send("can_#{permission_name}?", current_user) : true
		  has_controller_permission = controller.send("can_#{permission_name}?", current_user)
      
      # default options
		  options = { :link_text    => default_title = dynamic_link_catcher_default_link_text(permission_name, model_name.tableize),
		              :image_tag    => image_tag( "/images/#{permission_name}_16x16.png",
		                                          :title => default_title,
		                                          :alt => default_title ),
                  :options      => {},
                  :html_options => {}
	              }.merge(options)
	    
	    # return the correspondong link_to tag if permissions are allowing that!
      if has_controller_permission and has_model_permission
			  link_content = "#{options[:image_tag]} #{options[:link_text]}"
        
        # eval url-genrator method : user_path(1) => '/users/1' , edit_user_group_path(1,1) => '/users/1/groups/1/edit'
        complete_path_method = "#{path_name}_path("
        args_objects.each_index do |i|
          complete_path_method << ", " unless i == 0
          complete_path_method << "args_objects[#{i}]"
        end
        complete_path_method << "#{"," unless args_objects.empty?} options[:options]" unless options[:options].empty?
        complete_path_method << ")"
        link_url = eval(complete_path_method)
        
        options[:html_options] = options[:html_options].merge({ :method => :delete, :confirm => "Are you sure?" }) if permission_name == :delete
        
        link_to( link_content, link_url, options[:html_options] )
      end
    end
    
    # check if all objects passed into args correspond to the helper name
    #
    # ==== Examples
    #   dynamic_link_catcher_check_arguments_objects( ["user", "group"], [ @user, @group] )  # => no raise
    #
    #   dynamic_link_catcher_check_arguments_objects( ["user", "group"], [ @user ] )         # => raise exception
    #
    #   dynamic_link_catcher_check_arguments_objects( ["user", "group"], [ @group, @user ] ) # => raise exception
    #
    def dynamic_link_catcher_check_arguments_objects(expected_objects, args_objects)
      objects = args_objects.collect{ |o| o.class.to_s.tableize.singularize }
      
      expected_objects.each_with_index do |expected_object, index|
        unless objects[index] == expected_object
          raise ArgumentError, "expected a '#{expected_object.titleize}' object instance, but received a '#{objects[index].titleize}' one instead"
        end
      end
    end

    # retrives the model name and the method name from the called method
    # 
    # ==== Examples
    #   dynamic_link_catcher_retrieve_method_infos("edit_user_link")
    #   # => { :model_name => "user", :path_name => "edit_user" }
    # 
    #   dynamic_link_catcher_retrieve_method_infos("new_great_model_link")
    #   # => { :model_name => "great_model", :path_name => "new_great_model" }
    #
    #   dynamic_link_catcher_retrieve_method_infos("new_great_model_sub_model_link")
    #   # => { :model_name => "sub_model", :path_name => "new_great_model_sub_model" }
    # 
    def dynamic_link_catcher_retrieve_method_infos(method, args_objects)
      path = method.split("_")   # "formatted_new_great_model_link" => [ "formatted", "new", "great", "model", "link" ]
      path.pop 
      models = path.reject{ |s| %W{ formatted new edit delete }.include?(s) } # [ "formatted", "new", "great", "model" ] => [ "great", "model" ]
      infos = dynamic_link_catcher_retrieve_resources_model_infos(models, args_objects)
      model_name = infos[:model]
      nested_resources = infos[:nested_resources]
      
      { :model_name => model_name, :path_name => path.join("_"), :expected_objects => nested_resources}
    end
    
    # retrieve infos about the nested resources and the model which are implied in the path method
    #
    # ==== Examples
    #   dynamic_link_catcher_retrieve_resources_model_infos( [ "user" ], [ @user ] )
    #   # =>  { :nested_resources => [], :model => "user"}
    #
    #   dynamic_link_catcher_retrieve_resources_model_infos( [ "user" ], [] )
    #   # =>  { :nested_resources => [], :model => "user"}
    #
    #   dynamic_link_catcher_retrieve_resources_model_infos( [ "user", "group", "type" ], [ @user, @group_type ] )
    #   # =>  { :nested_resources => [ "user" ], :model => "group_type"}
    #
    #   dynamic_link_catcher_retrieve_resources_model_infos( ["user", "role", "group", "type" ], [ @user, @role, @group_type ])
    #   # =>  { :nested_resources => [ "user", "role" ], :model =>"group_type"}
    def dynamic_link_catcher_retrieve_resources_model_infos(models, args_objects)
      original_path_name = models.join("_") + "_path"
      models = models.join("_")
      args_class_names = args_objects.collect{ |o| o.class.to_s.tableize.singularize }
      
      args_class_names.each do |class_name|
        if models.include?(class_name)
          models = models.gsub("#{class_name}_","")
        else
          raise "the parameter object '#{class_name}' doesn't match to the model specified in the called method '#{original_path_name}'"
        end
      end
      args_class_names.delete(models)
      
      return { :nested_resources => args_class_names, :model => models}
    end
    
    # returns a readable link text according to the given method and model
    # 
    # ==== Examples
	  #   dynamic_link_catcher_default_link_text(:edit, "user")
	  #   # => "Edit current user"
	  # 
	  #   dynamic_link_catcher_default_link_text(:add, "great_model")
    #   # => "New great model"
    # 
    #   dynamic_link_catcher_default_link_text(:list, "group")
    #   # => "List all groups"
    # 
    def dynamic_link_catcher_default_link_text(method_name, model_name)
      default_text = { :list    => "List all ",
                       :view    => "View this ",
										   :add     => "New ",
										   :edit    => "Edit this ",
										   :delete  => "Delete this " }

      result = default_text[method_name] + model_name.gsub("_"," ")
      result = result.singularize unless method_name == :list
      return result
    end
    
    def url_for_menu(menu)
      # OPTIMIZE optimize this IF block code
      if menu.name
        path = "#{menu.name}_path"
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
    
    def current_menu
      menu = controller.controller_name
      Menu.find_by_name(menu) or raise "The controller '#{menu}' should have a menu with the same name"
    end
    
    def display_menu_entries(current)
      real_current_menu = current_menu
      output = ""
      
      if current.parent
        output << display_menu_entries(current.parent)
        siblings = Menu.find_by_parent_id(current.parent_id).self_and_siblings.activated
      else
        siblings = Menu.mains.activated
      end
      
      more_link = real_current_menu == current ? '' : link_to(content_tag(:em, 'More'), '#more', :class => 'nav_more')
      
      if real_current_menu.parent
        unless current.parent
          output << content_tag(:h4, link_to('Menu Principal', '/') + more_link, :title => "Menu Principal")
        else
          h4_options = real_current_menu == current ? { :class => 'nav_current' } : {}
          output << content_tag(:h4, link_to(current.parent.title, url_for_menu(current.parent), :title => current.parent.description) + more_link, h4_options)
        end
      end
      output << "<ul#{' class="nav_top"' unless real_current_menu == current}>"
      siblings.each do |menu|
        li_options = ( menu == current or menu.ancestors.include?(current) ) ? { :class => 'selected' } : {}
        output << display_menu_entry(menu, li_options)
      end
      output << "</ul>"
    end
    
    def display_menu_entry(menu, li_options)
      content_tag(:li, link_to(menu.title, url_for_menu(menu), :title => menu.description), li_options)
    end
end
