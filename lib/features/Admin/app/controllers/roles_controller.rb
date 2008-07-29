class RolesController < ApplicationController
  # GET /roles
  def index
    @roles = Role.find(:all)
  end

  # GET /roles/1
  def show
    @role = Role.find(params[:id])
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = 'Le Rôle a été ajouté avec succés.'
      redirect_to(@role) 
    else
      render :action => "new" 
    end
  end

  # PUT /roles/1
  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = 'Le Rôle a été mis-à-jour avec succés.'
      redirect_to(@role)
    else
      render :action => "edit" 
    end
  end

  # DELETE /roles/1
  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to(roles_url) 
  end
  

end

