// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../../core/const/app_colors.dart';
// import '../../../../core/const/gradientButton.dart';
// import '../../forgetPass/screens/forgetpassScreen.dart';
// import '../../signUp/screens/signScreen.dart';
// import '../controller/loginController.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final LoginController controller = Get.put(LoginController());

//     return Scaffold(
//       backgroundColor: AppColors.bgColor,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const SizedBox(height: 80.0),
//               Center(
//                 child: Image.asset(
//                   'assets/icons/logo.png',
//                   width: 200,
//                   height: 200,
//                 ),
//               ),
//               const SizedBox(height: 50.0),
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

//               SizedBox(height: 40),

//               Obx(() => TextField(
//                 obscureText: !controller.isPasswordVisible.value,
//                 decoration: InputDecoration(
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       controller.isPasswordVisible.value
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: AppColors.primaryColor,
//                     ),
//                     onPressed: controller.togglePasswordVisibility,
//                   ),
//                   labelText: 'Password',
//                   labelStyle: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 18,
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   floatingLabelStyle: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 18,
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   hintText: 'Enter Your Password',
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Colors.grey,
//                       width: 2.0,
//                     ),
//                   ),
//                 ),
//               )),

//               const SizedBox(height: 10),


//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Get.to(forgetpassScreen());
//                   },
//                   child: Text(
//                     'Forgot Password',
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),





//               /// Terms Checkbox
//               Obx(() => Row(
//                 children: [
//                   Checkbox(
//                     value: controller.agreedToTerms.value,
//                     onChanged: controller.toggleTermsAgreement,
//                     activeColor: AppColors.primaryColor,
//                   ),
//                   Expanded(
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'By Signing up you\'re agree to our ',
//                         style: GoogleFonts.roboto(

//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                         children: <TextSpan>[
//                            TextSpan(
//                             text: 'Terms & Conditions',
//                             style: GoogleFonts.roboto(

//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                           TextSpan(
//                             text: ' and ',
//                             style: GoogleFonts.roboto(

//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           TextSpan(
//                             text: 'Privacy Policy',
//                             style:
//                             GoogleFonts.roboto(

//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )),

//               const SizedBox(height: 30.0),

//               /// Log In Button
//               GradientButton(
//                 text: 'Log In',
//                 onPressed: () {

//                 },

//               ),


//               const SizedBox(height: 30.0),

//               /// Social Login
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _socialIcon(
//                     url:
//                     'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/640px-Google_Favicon_2025.svg.png',
//                     fallbackIcon: Icons.g_mobiledata,
//                   ),
//                   const SizedBox(width: 30.0),
//                   _socialIcon(
//                     url:
//                     'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg',
//                     fallbackIcon: Icons.apple,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 40.0),

//               /// Sign Up Prompt
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Text(
//                     'Don\'t have an account? ',
//                     style: GoogleFonts.roboto(

//                       color: Colors.grey[700],
//                       fontSize: 18,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Get.off(signScreen());
//                     },
//                     child:  Text(
//                       'Sign up',
//                       style: GoogleFonts.roboto(
//                         color: AppColors.primaryColor,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 40.0),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _socialIcon({required String url, required IconData fallbackIcon}) {
//     return GestureDetector(
//       onTap: () {
//         // Handle social login
//       },
//       child: Image.network(
//         url,
//         height: 47,
//         width: 47,
//         errorBuilder: (context, error, stackTrace) =>
//             Icon(fallbackIcon, size: 60),
//       ),
//     );
//   }
// }
