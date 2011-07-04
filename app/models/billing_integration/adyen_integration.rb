require 'adyen'

class BillingIntegration::AdyenIntegration < BillingIntegration
  preference :merchant_account, :string
  preference :skin_code, :string
  preference :shared_secret, :string
  
  def provider_class
    self.class
  end
  
  def self.current
    BillingIntegration::AdyenIntegration.first(
                  :conditions => {
                        :environment => RAILS_ENV.to_s,
                        :active => true
                  })
  end
  
  def generate_url(order)
    configure_adyen_gem()    
  
    order.update_totals
    total = (order.total * 100).to_i
    adyen_url = Adyen::Form.redirect_url(:skin => preferred_skin_code, :currency_code => 'EUR', :payment_amount => total,
      :merchant_account => preferred_merchant_account, :ship_before_date => Time.now + 7.days, :session_validity => Time.now + 10.minutes,
      :merchant_reference => order.number, :shopper_email => order.email, :shopper_reference => order.email)
    adyen_url   
  end
  
  private
  
  def configure_adyen_gem()
    Adyen.configuration.environment=(preferred_test_mode && "test" || "live")
    skin = Adyen.configuration.form_skin_by_name(preferred_skin_code) || Adyen.configuration.register_form_skin(preferred_skin_code, preferred_skin_code, preferred_shared_secret)
    skin
  end
end
