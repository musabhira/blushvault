import 'dart:js';

void openRazorpayWeb(
  Map<String, dynamic> options,
  Function(String) onSuccess,
  Function(String) onFailure,
) {
  try {
    // Verify Razorpay is loaded
    if (!context.hasProperty('Razorpay')) {
      onFailure('Razorpay SDK not loaded in index.html');
      return;
    }

    // Create Razorpay instance using the constructor: new Razorpay(options)
    final razorpay = JsObject(context['Razorpay'], [
      JsObject.jsify({
        ...options,
        // Handler must be wrapped in allowInterop
        'handler': allowInterop((response) {
          // response is a JsObject, access fields like a Map
          final paymentId = response['razorpay_payment_id'];
          onSuccess(paymentId);
        }),
        'modal': {
          'ondismiss': allowInterop(() {
            onFailure('Payment Cancelled');
          }),
        },
      })
    ]);

    // Open Checkout
    razorpay.callMethod('open');
  } catch (e) {
    onFailure('Web Payment Error: $e');
  }
}
