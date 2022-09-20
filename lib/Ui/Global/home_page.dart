import 'package:flutter/material.dart';
import 'package:peanut/App/properties.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Ui/Global/app_bar.dart';
import 'package:peanut/Ui/Global/navigation_bar.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/home";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Properties.onBack(context),
      child: Scaffold(
        extendBody: true,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add, color: PeanutTheme.secondaryColor),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: const PeanutAppBar(),
        bottomNavigationBar: const PeanutNavigationBar(),
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
}
