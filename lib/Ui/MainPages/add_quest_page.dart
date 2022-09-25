import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/map_model.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Ui/MainPages/map_selection_page.dart';
import 'package:peanut/Utils/text_utils.dart';

class AddQuestPage extends StatefulWidget {
  static const routeName = "/add-quest";
  const AddQuestPage({super.key});

  @override
  State<AddQuestPage> createState() => _AddQuestPageState();
}

class _AddQuestPageState extends State<AddQuestPage> {
  final _startLoc = TextEditingController();
  final _startLocFocus = FocusNode();
  final _quest = Quest.empty();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _startLoc.dispose();
    _startLocFocus.dispose();
    super.dispose();
  }

  void _setStartLocation(MapModel? location) => setState(() {
        _quest.startLocation = location;
        _startLoc.text = location?.addr ?? "";
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _floatingBtn(),
      appBar: AppBar(title: const Text("Create Quest")),
      body: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: _body(),
        ),
      ),
    );
  }

  Widget _floatingBtn() => KeyboardVisibilityBuilder(
        builder: (_, isKeyboardVisible) => Visibility(
          visible: !isKeyboardVisible,
          child: FloatingActionButton.extended(
            heroTag: "FAB",
            onPressed: () => false,
            label: Row(
              children: const [
                Icon(Icons.add, color: PeanutTheme.almostBlack),
                SizedBox(width: 10),
                Text("Create Quest"),
              ],
            ),
          ),
        ),
      );

  Widget _body() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _startLocation(),
          ],
        ),
      );

  Widget _startLocation() => Hero(
        tag: "start_location",
        child: Material(
          type: MaterialType.transparency,
          child: PeanutTextFormField(
            tooltipMsg: "This will determine your quest marker",
            controller: _startLoc,
            focus: _startLocFocus,
            hint: "Start Location",
            suffixIcon: const Icon(Icons.arrow_circle_right_rounded, color: PeanutTheme.almostBlack),
            validator: (value) => value == null || value.isEmpty ? "Required" : null,
            readOnly: true,
            onTap: () async => await Navigation.push(context, MapSelectionPage.routeName, args: [_quest.startLocation, _setStartLocation]),
          ),
        ),
      );
}

class PeanutTextFormField extends StatelessWidget {
  final String? hint;
  final String? tooltipMsg;

  final int? maxLine;
  final int? minLine;
  final int? maxLength;

  final bool readOnly;
  final bool enableTitleCase;

  final FocusNode? focus;
  final FocusNode? nextFocus;

  final TextEditingController? controller;

  final Widget? suffixIcon;

  final String? Function(String? value)? validator;
  final void Function()? onTap;
  final void Function(String value)? onChange;
  final void Function(String? value)? onSave;

  const PeanutTextFormField({
    super.key,
    this.controller,
    this.maxLine = 1,
    this.minLine,
    this.maxLength,
    this.hint,
    this.tooltipMsg,
    this.readOnly = false,
    this.enableTitleCase = false,
    this.focus,
    this.nextFocus,
    this.suffixIcon,
    this.validator,
    this.onTap,
    this.onChange,
    this.onSave,
  });

  InputDecoration decoration() => InputDecoration(
        filled: true,
        fillColor: PeanutTheme.white,
        border: const OutlineInputBorder(),
        labelText: hint,
        suffixIcon: suffixIcon,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: PeanutTheme.errorColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: PeanutTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: PeanutTheme.secondaryColor),
        ),
      );

  void onFieldSubmitted(BuildContext context) {
    focus?.unfocus();
    if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: textFormField(context)),
        if (tooltipMsg != null) const SizedBox(width: 5),
        if (tooltipMsg != null) tooltip(),
      ],
    );
  }

  Widget textFormField(BuildContext context) => TextFormField(
        controller: controller,
        readOnly: readOnly,
        autofocus: false,
        focusNode: focus,
        maxLines: maxLine,
        minLines: minLine,
        maxLength: maxLength,
        style: const TextStyle(color: PeanutTheme.almostBlack),
        decoration: decoration(),
        textCapitalization: enableTitleCase ? TextCapitalization.words : TextCapitalization.none,
        inputFormatters: enableTitleCase ? [TitleCaseTextFormatter()] : null,
        onFieldSubmitted: (_) => onFieldSubmitted(context),
        onTap: onTap,
        onChanged: onChange,
        onSaved: onSave,
        validator: validator,
      );

  Widget tooltip() => Tooltip(
        message: tooltipMsg,
        child: Icon(Icons.help, color: PeanutTheme.primaryColor.withOpacity(0.8), size: 19),
      );
}
