module Spree::CheckoutControllerWithAdyenIntegration
  def self.included(target)
    target.before_filter :redirect_to_adyen_form, :only => [:update]
  end
  
  private
end
