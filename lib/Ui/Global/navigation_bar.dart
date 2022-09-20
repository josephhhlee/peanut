import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:peanut/App/properties.dart';
import 'package:peanut/App/theme.dart';

class PeanutNavigationBar extends StatelessWidget {
  const PeanutNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Properties.navigationBarIndex,
      builder: (_, value, __) => AnimatedBottomNavigationBar(
        icons: Properties.icons,
        activeIndex: value,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        onTap: (index) => Properties.navigationBarIndex.value = index,
        activeColor: PeanutTheme.primaryColor,
        backgroundColor: PeanutTheme.almostBlack,
        inactiveColor: PeanutTheme.white,
        borderColor: PeanutTheme.secondaryColor,
      ),
    );
  }
}
