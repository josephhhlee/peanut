import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:peanut/App/properties.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Ui/Global/app_bar.dart';
import 'package:peanut/Ui/Global/navigation_bar.dart';
import 'package:peanut/Ui/MainPages/add_quest_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _borderRadiusAnimationController;
  late final Animation<double> _borderRadiusAnimation;

  @override
  void initState() {
    _borderRadiusAnimationController = AnimationController(duration: const Duration(milliseconds: 200), reverseDuration: const Duration(milliseconds: 200), vsync: this);
    final borderRadiusCurve = CurvedAnimation(parent: _borderRadiusAnimationController, curve: const Interval(0.5, 1.0, curve: Curves.bounceInOut));
    _borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(borderRadiusCurve);
    _borderRadiusAnimationController.forward();

    Properties.navigationBarIndex.addListener(_animationListener);
    super.initState();
  }

  @override
  void dispose() {
    _borderRadiusAnimationController.dispose();
    Properties.navigationBarIndex.removeListener(_animationListener);
    super.dispose();
  }

  void _animationListener() => Properties.navigationBarIndex.value != 0 ? _borderRadiusAnimationController.reverse() : _borderRadiusAnimationController.forward();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Properties.onBack(context),
      child: Scaffold(
        extendBody: true,
        floatingActionButton: _fab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: const PeanutAppBar(),
        bottomNavigationBar: PeanutNavigationBar(_borderRadiusAnimation),
        body: ValueListenableBuilder(
          valueListenable: Properties.navigationBarIndex,
          builder: (_, value, __) => IndexedStack(
            index: value,
            children: Properties.screens,
          ),
        ),
      ),
    );
  }

  Widget _fab() => AnimatedSize(
        clipBehavior: Clip.antiAlias,
        curve: Curves.bounceInOut,
        reverseDuration: const Duration(milliseconds: 200),
        duration: const Duration(milliseconds: 200),
        child: ValueListenableBuilder(
          valueListenable: Properties.navigationBarIndex,
          builder: (_, value, __) => Visibility(
            visible: value == 0,
            child: FloatingActionButton(
              heroTag: "FAB",
              tooltip: "Create Quest",
              onPressed: () async => await Navigation.push(context, AddQuestPage.routeName),
              child: const Icon(Icons.add, color: PeanutTheme.secondaryColor),
            ),
          ),
        ),
      );
}