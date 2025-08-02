// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kev23brown/feature/auth/forgetPass/screens/resetPassScreen.dart';
// import 'package:pin_input_text_field/pin_input_text_field.dart';

// import '../../../../core/const/app_colors.dart';
// import '../../../../core/const/gradientButton.dart';
// import '../../signUp/screens/signScreen.dart';

// class otpVerificationScreen extends StatelessWidget {
//   const otpVerificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgColor,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 80.0),
//               Center(
//                 child: Image.asset(
//                   'assets/icons/logo.png',
//                   width: 200,
//                   height: 200,
//                 ),
//               ),
//               const SizedBox(height: 50.0),
//               const Icon(Icons.lock, size: 40),
//               const SizedBox(height: 30.0),
//               Text(
//                 "OTP",
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 70),

//               SizedBox(
//                 height: 60, // Total height for input field area
//                 child: PinInputTextField(
//                   pinLength: 4,
//                   decoration: BoxLooseDecoration(
//                     strokeColorBuilder: PinListenColorBuilder(
//                       Colors.grey,
//                       AppColors.primaryColor,
//                     ),
//                     radius: Radius.circular(3),
//                     strokeWidth: 1,
//                     gapSpace: 40, // spacing between boxes
//                   ),
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                   // textStyle: const TextStyle(
//                   //   fontFamily: 'Inter',
//                   //   fontSize: 24,
//                   //   fontWeight: FontWeight.bold,
//                   //   color: Colors.black,
//                   // ),
//                   onChanged: (value) {},
//                   onSubmit: (pin) {
//                     print('Entered PIN: $pin');
//                   },
//                 ),
//               ),

//               const SizedBox(height: 30.0),

//               /// Verify Button
//               GradientButton(
//                 text: 'Verify',
//                 onPressed: () {
//                  Get.to(resetPassScreen());
//                 },
//               ),

//               const SizedBox(height: 30.0),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     'Don’t Get OTP? ',
//                     style: GoogleFonts.roboto(

//                       color: Colors.grey[700],
//                       fontSize: 18,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {

//                     },
//                     child:  Text(
//                       'Resend',
//                       style: GoogleFonts.roboto(
//                         color: AppColors.primaryColor,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
