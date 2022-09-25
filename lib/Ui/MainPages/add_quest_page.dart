import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/map_model.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Ui/MainPages/map_selection_page.dart';
import 'package:peanut/Utils/loading_utils.dart';
import 'package:peanut/Utils/text_utils.dart';

class AddQuestPage extends StatefulWidget {
  static const routeName = "/add-quest";
  const AddQuestPage({super.key});

  @override
  State<AddQuestPage> createState() => _AddQuestPageState();
}

class _AddQuestPageState extends State<AddQuestPage> {
  final _formKey = GlobalKey<FormState>();
  final _questLocation = TextEditingController();
  final _rewards = TextEditingController();
  final _description = TextEditingController();
  final _title = TextEditingController();
  final _rewardsFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _questLocationFocus = FocusNode();
  final _titleFocus = FocusNode();
  final _quest = Quest.empty();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _questLocation.dispose();
    _questLocationFocus.dispose();
    _rewards.dispose();
    _rewardsFocus.dispose();
    _description.dispose();
    _descriptionFocus.dispose();
    _title.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _setStartLocation(MapModel? location) => setState(() {
        _quest.mapModel = location;
        _questLocation.text = location?.addr ?? "";
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _floatingBtn(),
      appBar: AppBar(title: const Text("Create Quest")),
      body: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: _body(),
      ),
    );
  }

  Widget _floatingBtn() => KeyboardVisibilityBuilder(
        builder: (_, isKeyboardVisible) => Visibility(
          visible: !isKeyboardVisible,
          child: FloatingActionButton.extended(
            heroTag: "FAB",
            onPressed: () async {
              final form = _formKey.currentState;
              if (form?.validate() ?? false) {
                form?.save();
                LoadingOverlay.build(context);
                _quest.create().whenComplete(() {
                  LoadingOverlay.pop();
                  Navigator.pop(context);
                });
              }
            },
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

  Widget _body() => Form(
        key: _formKey,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _titleField(),
              const SizedBox(height: 20),
              _questLocationField(),
              const SizedBox(height: 20),
              _rewardsField(),
              const SizedBox(height: 20),
              Expanded(child: _descriptionField()),
              KeyboardVisibilityBuilder(
                builder: (_, isKeyboardVisible) => Visibility(
                  visible: !isKeyboardVisible,
                  child: const SizedBox(height: 75),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _titleField() => PeanutTextFormField(
        controller: _title,
        focus: _titleFocus,
        maxLength: Configs.emailCharLimit,
        nextFocus: _questLocationFocus,
        label: "Quest Title",
        enableTitleCase: true,
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        onSave: (value) => _quest.title = value?.trim(),
      );

  Widget _questLocationField() => Hero(
        tag: "quest_location",
        child: Material(
          type: MaterialType.transparency,
          child: PeanutTextFormField(
            tooltipMsg: "This will determine your quest marker",
            controller: _questLocation,
            focus: _questLocationFocus,
            nextFocus: _rewardsFocus,
            label: "Quest Location",
            suffixIcon: const Icon(Icons.arrow_circle_right_rounded, color: PeanutTheme.almostBlack),
            validator: (value) => value == null || value.isEmpty ? "Required" : null,
            readOnly: true,
            onTap: () async =>
                await Navigation.push(context, MapSelectionPage.routeName, args: [_quest.mapModel, _setStartLocation]).whenComplete(() => FocusScope.of(context).requestFocus(_rewardsFocus)),
          ),
        ),
      );

  Widget _rewardsField() => PeanutTextFormField(
        tooltipMsg: "Rewards for question completion",
        controller: _rewards,
        focus: _rewardsFocus,
        nextFocus: _descriptionFocus,
        label: "Rewards",
        numbersOnly: true,
        prefixIcon: Image.asset(
          "assets/currency.png",
          fit: BoxFit.scaleDown,
          scale: 35,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Required";
          if (int.tryParse(value) == null) return "Invalid value";
          if (int.parse(value) < 1) return "Minimum of 1 Peanut is required";
          return null;
        },
        onSave: (value) => _quest.rewards = int.parse(value!),
      );

  Widget _descriptionField() => PeanutTextFormField(
        controller: _description,
        focus: _descriptionFocus,
        hint: "Describe the instructions and\nobjectives of your quest..",
        isDescription: true,
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        onSave: (value) => _quest.description = value,
      );
}

class PeanutTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? tooltipMsg;

  final int? maxLine;
  final int? minLine;
  final int? maxLength;

  final bool readOnly;
  final bool enableTitleCase;
  final bool numbersOnly;
  final bool isDescription;

  final FocusNode? focus;
  final FocusNode? nextFocus;

  final TextEditingController? controller;

  final Widget? suffixIcon;
  final Widget? prefixIcon;

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
    this.label,
    this.hint,
    this.tooltipMsg,
    this.readOnly = false,
    this.enableTitleCase = false,
    this.numbersOnly = false,
    this.isDescription = false,
    this.focus,
    this.nextFocus,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.onTap,
    this.onChange,
    this.onSave,
  });

  InputDecoration decoration() => InputDecoration(
        filled: true,
        fillColor: PeanutTheme.white,
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        counterText: "",
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: PeanutTheme.errorColor),
        ),
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
        expands: isDescription,
        textAlignVertical: TextAlignVertical.top,
        controller: controller,
        readOnly: readOnly,
        autofocus: false,
        focusNode: focus,
        maxLines: isDescription ? null : maxLine,
        minLines: minLine,
        maxLength: isDescription ? Configs.descriptionCharLimit : maxLength,
        style: const TextStyle(color: PeanutTheme.almostBlack),
        decoration: decoration(),
        keyboardType: isDescription
            ? TextInputType.multiline
            : numbersOnly
                ? TextInputType.number
                : null,
        textCapitalization: enableTitleCase ? TextCapitalization.words : TextCapitalization.none,
        inputFormatters: enableTitleCase
            ? [TitleCaseTextFormatter()]
            : numbersOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
        onFieldSubmitted: (_) => onFieldSubmitted(context),
        onTap: onTap,
        onChanged: onChange == null ? null : (value) => onChange!(value.trim()),
        onSaved: onSave == null ? null : (value) => onSave!(value?.trim()),
        validator: validator == null ? null : (value) => validator!(value?.trim()),
      );

  Widget tooltip() => Tooltip(
        message: tooltipMsg,
        child: Icon(Icons.help, color: PeanutTheme.primaryColor.withOpacity(0.8), size: 19),
      );
}
