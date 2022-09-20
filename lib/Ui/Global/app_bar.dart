import 'package:flutter/material.dart';
import 'package:peanut/App/properties.dart';
import 'package:sprung/sprung.dart';

class PeanutAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PeanutAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Sprung.overDamped,
      width: double.infinity,
      child: ValueListenableBuilder(
        valueListenable: Properties.navigationBarIndex,
        builder: (context, value, child) => Visibility(
          visible: value != 0,
          child: AppBar(
            title: Text(Properties.titles[value]),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
    );
  }
}
