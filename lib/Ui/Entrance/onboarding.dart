import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'dart:developer';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final key = "onboarding";
  final PageController _pageController = PageController();
  List<Map>? _details;

  int _currentPage = 0;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    Future<void> retrieveDetails() async {
      try {
        var doc = await FirestoreService.appConfigs.doc(key).get();
        if (doc.get("activate")) {
          _details = List.from(doc.get("pages"));
          if (mounted) setState(() {});
        }
      } catch (e) {
        log(e.toString());
        _details = null;
      }
    }

    bool display = DataStore().pref.getBool(key) ?? true;
    if (display) await retrieveDetails();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Visibility(
      visible: _details != null,
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: PeanutTheme.black.withOpacity(0.5),
        child: Card(child: _pageBuilder(screenSize)),
      ),
    );
  }

  Widget _pageBuilder(Size screenSize) => Material(
        type: MaterialType.transparency,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05, vertical: screenSize.height * 0.05),
          decoration: BoxDecoration(
            color: PeanutTheme.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _details?.length,
            onPageChanged: (value) => setState(() => _currentPage = value),
            itemBuilder: (_, index) => _contents(index),
          ),
        ),
      );

  Widget _contents(int index) {
    final imageUrl = _details?[index]["image"] ?? "";
    final title = _details?[index]["title"] ?? "";
    final description = _details?[index]["desc"] ?? "";
    final pageAtEnd = index + 1 == _details?.length;

    Widget image() => Expanded(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) => const SizedBox.shrink(),
          ),
        );

    Widget indicator() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _details!.map((element) {
            var onPage = _currentPage == _details!.indexOf(element);
            return Container(
              width: onPage ? 9 : 8,
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: PeanutTheme.primaryColor.withOpacity(onPage ? 1 : 0.5),
              ),
            );
          }).toList(),
        );

    Widget theTitle() => Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: PeanutTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        );

    Widget theDescription() => Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: PeanutTheme.almostBlack),
            ),
          ),
        );

    Widget button() => SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: () async {
              if (pageAtEnd) {
                await DataStore().pref.setBool(key, false);
                setState(() => _details = null);
              } else {
                _pageController.animateToPage(index + 1, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              fixedSize: Size(MediaQuery.of(context).size.width, 40),
            ),
            child: Text(
              pageAtEnd ? "Done" : "Next",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );

    Widget skip() => Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              await DataStore().pref.setBool(key, false);
              setState(() => _details = null);
            },
            child: const Text(
              "Skip",
              style: TextStyle(color: PeanutTheme.primaryColor, fontSize: 17),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image(),
              Flexible(
                flex: 3,
                child: SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ),
              indicator(),
              const SizedBox(height: 15),
              theTitle(),
              const SizedBox(height: 15),
              Flexible(
                flex: 1,
                child: theDescription(),
              ),
              const SizedBox(height: 20),
              button(),
            ],
          ),
          skip(),
        ],
      ),
    );
  }
}
