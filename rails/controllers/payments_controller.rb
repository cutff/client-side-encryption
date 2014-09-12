class PaymentsController < ApplicationController

  def index
    # You're supposed to serve the index.html.haml view here
  end

  def create
    # Handle the submited form found in the index.haml.html served in the index action above
    datas = {
        'action' => 'Payment.authorise',
        'paymentRequest.amount.currency' => 'EUR',
        'paymentRequest.amount.value'    => '10000',
        'paymentRequest.merchantAccount' => 'YOUR_MERCHANT_NAME',
        'paymentRequest.reference'       => 'example_order_1',
        'paymentRequest.additionalData.card.encrypted.json' => params['adyen-encrypted-data']
    }

    auth = {username: "ws@Company.YourCompany", password: "verys3cret"}
  
    req = HTTParty.post("https://pal-test.adyen.com/pal/adapter/httppost", basic_auth: auth, body: datas)

    render text: req.body
  end

end
