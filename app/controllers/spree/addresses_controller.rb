class Spree::AddressesController < Spree::BaseController
  helper Spree::AddressesHelper
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  load_and_authorize_resource
  
  def create
    params['address']['user_id'] = spree_current_user.id
    @address=Spree::Address.create(params['address'])
    if(@address.save)
      flash[:notice] = I18n.t(:successfully_created, :resource => I18n.t(:address))
      redirect_back_or_default(account_path)
    else
      flash[:error] = @address.errors.empty? ? "Error" : @address.errors.full_messages.join(', ')
      render :action => 'new'
    end
  end
  
  def edit
    session["user_return_to"] = request.env['HTTP_REFERER']
  end
  
  def update
    if @address.editable?
      if @address.update_attributes(params[:address])
        flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:address))
        redirect_back_or_default(account_path)
      else
        flash[:error] = @address.errors.empty? ? "Error" : @address.errors.full_messages.join(', ')
        render :action => 'edit'
      end
    else
      new_address = @address.clone
      new_address.attributes = params[:address]
      @address.update_attribute(:deleted_at, Time.now)
      if new_address.save
        flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:address))
        redirect_back_or_default(account_path)
      else
        flash[:error] = new_address.errors.empty? ? "Error" : new_address.errors.full_messages.join(', ')
        render :action => 'edit'
      end
    end
  end

  def destroy
    @address.destroy

    flash[:notice] = I18n.t(:successfully_removed, :resource => t(:address))
    redirect_to(request.env['HTTP_REFERER'] || account_path) unless request.xhr?
  end
end
