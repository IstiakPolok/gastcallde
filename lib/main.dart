import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gastcallde/core/localization/localization.dart';
import 'package:gastcallde/feature/orderManagment/controllers/order_controller.dart';
import 'package:gastcallde/route/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(OrderController());

  configEasyLoading();

  runApp(MyApp());
}

void configEasyLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.grey
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..maskColor = Colors.green
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  @override
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gast Call de',
        getPages: AppRoute.routes,
        initialRoute: AppRoute.splashScreen,
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          textTheme:
              GoogleFonts.poppinsTextTheme(), // Apply Philosopher globally
          // If you want to customize it further:
          // textTheme: GoogleFonts.philosopherTextTheme(
          //   Theme.of(context).textTheme,
          // ),
        ),
        builder: EasyLoading.init(),
      ),
    );
  }
}
