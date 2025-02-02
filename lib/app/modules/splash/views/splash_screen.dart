import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shopperz/config/routes/app_routes.dart';
import 'package:shopperz/utils/svg_icon.dart';

import '../../../../config/theme/app_color.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Get.offNamed(Routes.navBarView);
    });
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryBackgroundColor,
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0), // تعديل الزوايا حسب الرغبة
            child: Image.asset(
              "assets/images/Gas-Icon.png",
              height: 180.h,
              colorBlendMode: BlendMode.srcIn,
            ),
          )

        ),
      ),
    );
  }
}
