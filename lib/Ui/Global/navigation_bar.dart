import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:peanut/App/properties.dart';
import 'package:peanut/App/theme.dart';

class PeanutNavigationBar extends StatelessWidget {
  final Animation<double> borderRadiusAnimation;

  const PeanutNavigationBar(this.borderRadiusAnimation, {super.key});

  @override
  Widget build(BuildContext context) {
    final icons = Properties.icons;

    return ValueListenableBuilder(
      valueListenable: Properties.navigationBarIndex,
      builder: (_, value, __) => AnimatedBottomNavigationBar.builder(
        activeIndex: value,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) => Properties.navigationBarIndex.value = index,
        backgroundColor: PeanutTheme.almostBlack,
        borderColor: PeanutTheme.secondaryColor,
        itemCount: icons.length,
        notchAndCornersAnimation: borderRadiusAnimation,
        tabBuilder: (int index, bool isActive) {
          return Icon(
            icons[index],
            size: 24,
            color: isActive ? PeanutTheme.primaryColor : PeanutTheme.white,
          );
        },
      ),
    );
  }
}
