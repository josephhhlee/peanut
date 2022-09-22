import 'package:flutter/material.dart';

class AddQuestPage extends StatefulWidget {
  static const routeName = "/add-quest";
  const AddQuestPage({super.key});

  @override
  State<AddQuestPage> createState() => _AddQuestPageState();
}

class _AddQuestPageState extends State<AddQuestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _fab(),
      appBar: AppBar(title: const Text("Create Quest")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _fab() => FloatingActionButton.extended(
        heroTag: "FAB",
        onPressed: () => false,
        label: Row(
          children: const [
            Icon(Icons.save),
            SizedBox(width: 10),
            Text("Create Quest"),
          ],
        ),
      );
}
