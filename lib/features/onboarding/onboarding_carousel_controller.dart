import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingCarouselController extends GetxController {
  final pageController = PageController();
  final rxCurrentPage = 0.obs;

  int get currentPage => rxCurrentPage.value;

  void onPageChanged(int index) {
    rxCurrentPage.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
