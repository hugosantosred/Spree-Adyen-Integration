module Spree::AdyenIntegration
  include ERB::Util
  include ActiveMerchant::RequiresParameters
  
  def self.included(target)
    target.before_filter :redirect_to_adyen_form_if_needed, :only => [:update]
  end
  
  # Outbound redirect to Adyen from checkout payments step
  #
  def adyen_payment
    load_object
    opts = all_opts(@order,params[:payment_method_id], 'payment')
    opts.merge!(address_options(@order))
    gateway = adyen_gateway

    #if Spree::Config[:auto_capture]
    #  response = gateway.setup_purchase(opts[:money], opts)
    #else
    #  response = gateway.setup_authorization(opts[:money], opts)
    #end

    unless response.success?
      gateway_error(response)
      redirect_to edit_order_checkout_url(@order, :step => "payment")
      return
    end

    redirect_to (gateway.redirect_url_for response.token, :review => payment_method.preferred_review)
  rescue ActiveMerchant::ConnectionError => e
    gateway_error I18n.t(:unable_to_connect_to_gateway)
    redirect_to :back
  end
  
  private
  def redirect_to_adyen_form_if_needed
    debugger 
    return unless @current_order.state == "payment"    
    payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    debugger
    if payment_method.kind_of?(BillingIntegration::AdyenIntegration)
      redirect_to payment_method.generate_url(@current_order)
    end
  end
  
  def gateway_error(response)
    if response.is_a? ActiveMerchant::Billing::Response
      text = response.params['message'] ||
             response.params['response_reason_text'] ||
             response.message
    else
      text = response.to_s
    end

    msg = "#{I18n.t('gateway_error')}: #{text}"
    logger.error(msg)
    flash[:error] = msg
  end
  
  def payment_method
    PaymentMethod.find(params[:payment_method_id])
  end

  def adyen_gateway
    payment_method.provider
  end
end
