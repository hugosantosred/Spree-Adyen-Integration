class AdyenSource < ActiveRecord::Base
  belongs_to :payment
  
  validates_presence_of :psp_reference, :p_method
  
  def payment_gateway
     BillingIntegration::AdyenIntegration.current
  end
  
end
