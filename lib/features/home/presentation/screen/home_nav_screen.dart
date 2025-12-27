import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/features/business/presentation/screen/business_screen.dart';
import 'package:road_project_flutter/features/gym_screen/presentaion/screens/gymscreen.dart';
import 'package:road_project_flutter/features/mealscreen/presentation/screen/meal_screen.dart';
import 'package:road_project_flutter/features/profile/presentaion/controller/feature_access_controller.dart';
import 'package:road_project_flutter/features/profile/presentaion/screen/profile_screen.dart';
import 'package:road_project_flutter/features/store/presentation/screen/store_screen.dart';
import '../../../../utils/constants/app_colors.dart';
import 'home_screen.dart';

class HomeNavScreen extends StatelessWidget {
  HomeNavScreen({super.key}) {
    Get.put(HomeNavController());
    if (!Get.isRegistered<FeatureAccessController>()) {
      Get.put(FeatureAccessController(), permanent: true);
    }
  }

  final List<Map<String, String>> _navItems = [
    {"icon": "assets/icons/home.svg"},
    {"icon": "assets/icons/profile.svg"},
    {"icon": "assets/icons/defence.svg"},
    {"icon": "assets/icons/medias.svg"},
    {"icon": "assets/icons/buessness.svg"},
    {"icon": "assets/icons/store.svg"},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeNavController>();
    final accessController = Get.find<FeatureAccessController>();

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            controller.selectedIndex.value == 0
                ? _FeatureGate(
                    locked: !accessController.isLoading.value &&
                        !accessController.canAccessFeature.value,
                    onBuyTap: () => controller.changeIndex(5),
                    child: HomeScreen(),
                  )
                : Container(),
            controller.selectedIndex.value == 1
                ? _FeatureGate(
                    locked: !accessController.isLoading.value &&
                        !accessController.canAccessFeature.value,
                    onBuyTap: () => controller.changeIndex(5),
                    child: ProfileScreen(),
                  )
                : Container(),
            controller.selectedIndex.value == 2
                ? _FeatureGate(
                    locked: !accessController.isLoading.value &&
                        !accessController.canAccessFeature.value,
                    onBuyTap: () => controller.changeIndex(5),
                    child: GymScreen(),
                  )
                : Container(),
            controller.selectedIndex.value == 3
                ? _FeatureGate(
                    locked: !accessController.isLoading.value &&
                        !accessController.canAccessFeature.value,
                    onBuyTap: () => controller.changeIndex(5),
                    child: MealScreen(),
                  )
                : Container(),
            controller.selectedIndex.value == 4
                ? _FeatureGate(
                    locked: !accessController.isLoading.value &&
                        !accessController.canAccessFeature.value,
                    onBuyTap: () => controller.changeIndex(5),
                    child: BusinessScreen(),
                  )
                : Container(),
            controller.selectedIndex.value == 5 ? StoreScreen() : Container(),
          ],
        ),

        /// 🟢 Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.r),
              topRight: Radius.circular(4.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 2.r,
                offset: Offset(0, -2.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.r),
              topRight: Radius.circular(4.r),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xff151515),
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeIndex,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: const Color(0xffA1A1A1),
              showSelectedLabels: false, // hide text
              showUnselectedLabels: false, // hide text
              iconSize: 24.sp,
              elevation: 0,
              items: List.generate(_navItems.length, (index) {
                final isSelected = controller.selectedIndex.value == index;
                return BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 6.h),
                    child: SvgPicture.asset(
                      _navItems[index]["icon"]!,
                      width: 32.w,
                      height: 32.h,
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? AppColors.primaryColor
                            : const Color(0xffA1A1A1),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: '', // empty label
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeNavController extends GetxController {
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<FeatureAccessController>()) {
      Get.find<FeatureAccessController>().fetchAccess();
    }
    final argIndex = Get.arguments?['index'];
    if (argIndex != null) {
      selectedIndex.value = argIndex;
    }
  }

  void changeIndex(int index) {
    if (index == selectedIndex.value)
      return; // Prevent rebuilding if same index
    selectedIndex.value = index;
  }
}

class _FeatureGate extends StatelessWidget {
  final bool locked;
  final VoidCallback onBuyTap;
  final Widget child;

  const _FeatureGate({
    required this.locked,
    required this.onBuyTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: AbsorbPointer(
            absorbing: true,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 420.w),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your account does not have an active clothing purchase.\nPlease purchase Road to 1% apparel to unlock access to the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      //width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: onBuyTap,
                        child: Text(
                          'Buy Road to 1% Apparel',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
