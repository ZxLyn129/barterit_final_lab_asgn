import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_checkout/stripe_checkout.dart';

class StripeService {
  static String publishableKey =
      "pk_test_51NU3kyKZokqNk3zQJ9EnetrM4fRSaUdPD0Z4d5CRDZeTFkV7S8FuklYIrlNFLTXTvSsPTm1Cc5LtcoKmMoSJZUa300lh4exuKX";
  static String secretKey =
      "sk_test_51NU3kyKZokqNk3zQWXchsMFTo66LlSL1y2mdkXRAMdhFXVRix2uHj1ZE2gHnUsVw29NBfctAILrutH3DlPHwEgJw00d1zOR988";

  static Future<dynamic> createCheckoutSession(
    List<dynamic> item,
    totalAmount,
    double shippingFee,
  ) async {
    final url = Uri.parse("https://api.stripe.com/v1/checkout/sessions");

    String lineItem = "";
    int index = 0;

    for (var val in item) {
      var itemPrice = (double.parse(val['itemPrice']) * 100).round().toString();
      lineItem +=
          "&line_items[$index][price_data][product_data][name]=${val['itemName']}";
      lineItem += "&line_items[$index][price_data][unit_amount]=$itemPrice";
      lineItem += "&line_items[$index][price_data][currency]=MYR";
      lineItem += "&line_items[$index][quantity]=${val['qty'].toString()}";

      index++;
    }

    // Add shipping fee
    var shippingPrice = (shippingFee * 100).round().toString();
    lineItem +=
        "&line_items[$index][price_data][product_data][name]=Shipping Fee";
    lineItem += "&line_items[$index][price_data][unit_amount]=$shippingPrice";
    lineItem += "&line_items[$index][price_data][currency]=MYR";
    lineItem += "&line_items[$index][quantity]=1";

    final response = await http.post(
      url,
      body:
          'success_url=https://checkout.stripe.dev/success&mode=payment$lineItem',
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    final sessionData = jsonDecode(response.body);
    final sessionId = sessionData['id'];

    return sessionId;
  }

  static Future<String?> stripePaymentCheckout(
    List<dynamic> item,
    totalAmount,
    double shippingFee,
    context,
    mounted, {
    onSuccess,
    onCancel,
    onError,
  }) async {
    final sessionId = await createCheckoutSession(
      item,
      totalAmount,
      shippingFee,
    );

    final result = await redirectToCheckout(
      context: context,
      sessionId: sessionId,
      publishableKey: publishableKey,
      successUrl: "https://checkout.stripe.dev/success",
      canceledUrl: "https://checkout.stripe.dev/cancel",
    );

    if (mounted) {
      final text = result.when(
        redirected: () => 'Redirected Successfully',
        success: () async {
          final paymentIntentId = await retrievePaymentIntent(sessionId);

          onSuccess(paymentIntentId);
        },
        canceled: () => onCancel(),
        error: (e) {
          onError(e);
        },
      );

      return text;
    }
    return null;
  }

  static Future<String?> retrievePaymentIntent(String sessionId) async {
    final url =
        Uri.parse("https://api.stripe.com/v1/checkout/sessions/$sessionId");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    final sessionData = jsonDecode(response.body);
    final paymentIntentId = sessionData['payment_intent'];

    return paymentIntentId;
  }
}
