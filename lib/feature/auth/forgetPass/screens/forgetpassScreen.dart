// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../core/const/app_colors.dart';
// import '../../../../core/const/gradientButton.dart';
// import '../../signUp/screens/signScreen.dart';
// import 'otpVerificationScreen.dart';


// class forgetpassScreen extends StatelessWidget {
//   const forgetpassScreen({super.key});

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
//               Icon(Icons.lock,size: 40),
//               Text("Forgot Password",style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w500

//               ),),

//               SizedBox(height: 50),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'User Email',
//                   labelStyle: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 18,
//                     color: AppColors.primaryColor, // Color when inactive
//                     fontWeight: FontWeight.w600,
//                   ),
//                   // When the label floats (TextField is active/focused)
//                   floatingLabelStyle: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 18, // Larger size when active
//                     color: AppColors.primaryColor, // Change to any color you like
//                     fontWeight: FontWeight.bold,
//                   ),
//                   hintText: 'Enter Your Email',
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Colors.grey, // Border color when focused
//                       width: 2.0,
//                     ),
//                   ),
//                 ),
//               ),












//               const SizedBox(height: 30.0),

//               /// Log In Button
//               GradientButton(
//                 text: 'Verify',
//                 onPressed: () {
//                   Get.to(otpVerificationScreen());

//                 },

//               ),



//             ],
//           ),
//         ),
//       ),
//     );
//   }


// }
