// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:karthikrenkaraj/core/const/stripe_keys.dart'
//     show stripeSecretKey;

// class StripeService {
//   StripeService._();

//   static final StripeService instance = StripeService._();

//   Future<bool> makePayment(int amount) async {
//     try {
//       String? paymentIntentClientSecret = await _createPaymentIntent(
//         amount,
//         "usd",
//       );

//       if (paymentIntentClientSecret == null) {
//         if (kDebugMode) {
//           print("Payment Intent creation failed.");
//         }
//         return false;
//       }

//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentClientSecret,
//           merchantDisplayName: "Your Merchant Name",
//         ),
//       );

//       bool isPaymentSuccess = await _processPayment();
//       if (kDebugMode) {
//         print("////////////Payment successful result: $isPaymentSuccess");
//       }
//       return isPaymentSuccess;
//     } catch (e) {
//       if (kDebugMode) {
//         print("Payment failed: $e");
//       }
//       return false;
//     }
//   }

//   Future<bool> _processPayment() async {
//     try {
//       if (kDebugMode) {
//         print("////////// Presenting payment sheet...");
//       }
//       await Stripe.instance.presentPaymentSheet();
//       if (kDebugMode) {
//         print("////////// Payment confirmed successfully!");
//       }
//       return true;
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error processing payment: $e");
//       }
//       return false;
//     }
//   }

//   Future<String?> _createPaymentIntent(int amount, String currency) async {
//     try {
//       final Dio dio = Dio();
//       Map<String, dynamic> data = {
//         "amount": _calculateAmount(amount),
//         "currency": currency,
//       };
//       var response = await dio.post(
//         "https://api.stripe.com/v1/payment_intents",
//         data: data,
//         options: Options(
//           contentType: Headers.formUrlEncodedContentType,
//           headers: {
//             "Authorization": "Bearer $stripeSecretKey",
//             "Content-Type": 'application/x-www-form-urlencoded',
//           },
//         ),
//       );
//       if (response.data != null) {
//         return response.data["client_secret"];
//       }
//       return null;
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error creating payment intent: $e");
//       }
//       return null;
//     }
//   }

//   String _calculateAmount(int amount) {
//     final calculatedAmount = amount * 100;
//     return calculatedAmount.toString();
//   }
// }
