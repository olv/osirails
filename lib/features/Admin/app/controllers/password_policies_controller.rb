class PasswordPoliciesController < ApplicationController
  
  def index
  end
  
  def update
    if request.put?
     
     e = Employee.new(:last_name => "jean", :first_name => "paul", :society_email => "toto@emr-oi.fr",:email => "toto@emr-oi.fr",:social_security => "1111111111111 11")
     response = e.pattern(params[:pattern],e)
     reg = /^(pattern invalide : <br)+(\x2F)+(>- )[\x20-\x7E]*$/
     reg.match(response).nil? ? pattern_error = false : pattern_error = true 
     
      if !params[:level].nil? and params[:pattern]!="" and params[:validity]!="" and pattern_error == false
        ConfigurationManager.admin_actual_password_policy = params[:level]
        ConfigurationManager.admin_user_pattern = params[:pattern].to_s
        params[:validity].to_i < 0 ? ConfigurationManager.admin_password_validity = 0 : ConfigurationManager.admin_password_validity = params[:validity]
        flash[:notice] = "Modifications appliquées avec succés"
        redirect_to :action => "index"
      else
        flash[:error] = "Erreur : <ul>"
        flash[:error] += "<li> Vous devez séléctionner au moins une politique de mot de passe </li>" if params[:level].nil?
        flash[:error] += "<li> Le modèle de création d'user est invalide, consultez l'aide pour plus d'informations </li>" if params[:pattern]==""
        flash[:error] += "<li> Vous devez entrer une durée de validité du mot de passe </li>"  if params[:validity]==""
        flash[:error] += "<li>" + response + "</li>" unless pattern_error == false
        flash[:error] += "</ul>"
        
        flash.now[:error]
      end
        
      
    else
      flash[:error] = "Tentative de modification frauduleuse"
      redirect_to :action => "index"
    end
  end
  
end
