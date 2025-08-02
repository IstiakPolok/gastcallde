import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';
import '../../../bottom_nav_bar/screen/bottom_nav_bar.dart' hide AppColors;
import '../controllers/RoleSelectController.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoleSelectController()); // Initialize controller

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('The Mirror',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),)),
              Center(
                child: Image.asset(
                  'assets/image/mirror.png',
        
                  height: 290,
                ),
              ),
              SizedBox(height: 20,),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() => Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: controller.options.map((option) {
                      final isSelected =
                      controller.selectedOptions.contains(option);
                      return GestureDetector(
                        onTap: () => controller.toggleOption(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green[50]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30.0),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                option,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  color: isSelected
                                      ? Colors.green[800]
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(BottomNavbar());
                    final selected = controller.selectedOptions.toList();
                    if (selected.isEmpty) {
                      debugPrint('No options selected.');
                    } else {
                      debugPrint('Selected Options:');
                      for (var option in selected) {
                        debugPrint('- $option');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  child: const Text(
                    'Go',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
