class AdyenCallbackController < Spree::BaseController
  include ActiveMerchant::Billing::Integrations
  skip_before_filter :verify_authenticity_token
  def index
    order = Order.find_by_number(params[:merchantReference])
    
    payment_details = AdyenSource.create(
      :psp_reference => params[:pspReference],
      :p_method => params[:paymentMethod]      
      )
    payment_details.save!
    
    payment = order.payments.new(
      :amount => order.total,
      :payment_method => BillingIntegration::AdyenIntegration.current,
      :source => payment_details
      ) 
    payment.save
    #payment = order.payments.first(:conditions => {:source_type => "AdyenSource"})
    payment.started_processing
    payment.save
    
    payment_details.payment = payment
    payment_details.save!
    
    case params[:authResult]
    when "AUTHORISED"            
      order.finalize!
      order.process_payments!
      payment.complete
      payment.save!
      
      session[:order_id] = nil
      redirect_to order_url(order, {:checkout_complete => true, :order_token => order.token})
      
      return
    when "REFUSED"
      flash[:error] = "Ha ocurrido un error al procesar el pago: Se ha rechazado su tarjeta de crédito"

      payment.fail
      payment.save
      
      redirect_to edit_order_url(order)
      return
    when "CANCELLED"
      flash[:error] = "Ha cancelado el pago"
      
      payment.pend
      payment.save
      
      redirect_to edit_order_url(order)
      return
    when "ERROR"
      flash[:error] = "Ha ocurrido un error al procesar el pago"
      
      payment.fail
      payment.save
      
      redirect_to edit_order_url(order)
      return
    end
    
    
  end
end
