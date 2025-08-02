
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:kev23brown/core/const/app_colors.dart';

// import '../../../core/global_widegts/custom_button.dart';
// import '../../../core/style/global_text_style.dart';
// import '../../auth/login/screens/loginScreen.dart';



// class onBoardind2 extends StatelessWidget {
//   onBoardind2({super.key});



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
//           children: [
//             Image.asset(
//               'assets/image/onboardBG.png', // Replace with your image path
//               fit: BoxFit.cover, // Covers entire box while preserving aspect ratio
//             ),
        
        
        
//              // Space from the top of the screen
        
//             // "My journey" title
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Text(
//                 'My journey',
//                 style: TextStyle(
//                   fontFamily: 'Roboto', // Assuming 'Inter' font is available
//                   fontSize: 40, // Large font size for the main title
//                   fontWeight: FontWeight.w600, // Extra bold weight
//                   color: AppColors.primaryColor, // Dark green color
//                 ),
//               ),
//             ),
        
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: RichText(
//                 text: TextSpan(
//                   style: const TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 18,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.black87,
//                     height: 1.5,
//                   ),
//                   children: [
//                     const TextSpan(text: 'Your '),
//                     TextSpan(
//                       text: 'safe',
//                       style: const TextStyle(color: AppColors.primaryColor), // Highlighted in green
//                     ),
//                     const TextSpan(text: ' space for growth.'),
        
//                     TextSpan(
//                       text: ' Positive',
//                       style: const TextStyle(color: AppColors.primaryColor), // Highlighted in blue
//                     ),
        
//                     const TextSpan(
//                         text: ' content, real '),
//                     TextSpan(
//                       text: ' guidance',
//                       style: const TextStyle(color: AppColors.primaryColor), // Highlighted in blue
//                     ),
//                     const TextSpan(
//                         text: ' , and a supportive community to help you stay balanced and inspired.'),
        
//                   ],
//                 ),
//               ),
        
//             ),
        
//             const SizedBox(height: 30), // Space between paragraph and second heading
        
//             // Second heading
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Text(
//                 'Walk with people with a purpose to identify your purpose in life',
//                 style: TextStyle(
//                   fontFamily: 'Roboto', // Assuming 'Inter' font is available
//                   fontSize: 20, // Slightly larger font for this heading
//                   fontWeight: FontWeight.w500, // Semi-bold weight
//                   color:  AppColors.primaryColor, // Slightly darker green
//                   height: 1.4, // Line height
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
        
//             // Pushes the buttons to the bottom
        
//             // Buttons: Log In and Walk
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Row(
//                 children: [
//                   // Log In button (filled green)
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {

//                         Get.to(LoginScreen());
// ;                        print('Log In button pressed!');
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor, // Background color
//                         foregroundColor: Colors.white, // Text color
//                         padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12), // Rounded corners
//                         ),
//                         elevation: 0, // No shadow for a flat look
//                       ),
//                       child: const Text(
//                         'Log In',
//                         style: TextStyle(
//                           fontFamily: 'Roboto', // Assuming 'Inter' font is available
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
        
//                   const SizedBox(width: 16), // Space between buttons
        
//                   // Walk button (outlined)
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {
//                         // TODO: Implement Walk functionality
//                         print('Walk button pressed!');
//                       },
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: AppColors.primaryColor, // Text color
//                         padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding
//                         side: BorderSide(color: AppColors.primaryColor!, width: 2), // Green border
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12), // Rounded corners
//                         ),
//                       ),
//                       child: const Text(
//                         'Walk',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontFamily: 'Roboto', // Assuming 'Inter' font is available
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20), // Space from the bottom of the screen
//           ],
//         ),
//       ),
//     );
//   }


// }
