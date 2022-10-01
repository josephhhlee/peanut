import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:peanut/Utils/common_utils.dart';

class QuestList extends StatelessWidget {
  const QuestList({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: [
            _tabs(),
            Expanded(child: _contents()),
          ],
        ),
      ),
    );
  }

  Widget _tabs() => Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              color: PeanutTheme.primaryColor,
              alignment: Alignment.center,
              child: const Text(
                "Taken",
                textAlign: TextAlign.center,
                style: TextStyle(color: PeanutTheme.almostBlack, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 50,
              color: PeanutTheme.primaryColor,
              alignment: Alignment.center,
              child: const Text(
                "Created",
                textAlign: TextAlign.center,
                style: TextStyle(color: PeanutTheme.almostBlack, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );

  Widget _contents() => PageView(
        physics: const BouncingScrollPhysics(),
        pageSnapping: true,
        children: const [
          _QuestListTab(tab: "taken"),
          _QuestListTab(tab: "created"),
        ],
      );
}

class _QuestListTab extends StatefulWidget {
  final String tab;

  const _QuestListTab({required this.tab});

  @override
  State<_QuestListTab> createState() => __QuestListTabState();
}

class __QuestListTabState extends State<_QuestListTab> with AutomaticKeepAliveClientMixin<_QuestListTab> {
  final _searchController = TextEditingController();
  final List<MiniQuest> _questList = [];
  late final StreamSubscription<DocumentSnapshot> _questListener;

  bool _initialised = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _questListener.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _init() async {
    final uid = DataStore().currentUser!.uid;
    final ref = widget.tab == "taken" ? FirestoreService.userQuestListTakenDoc(uid) : FirestoreService.userQuestListCreatedDoc(uid);

    _questListener = ref.snapshots().listen((doc) {
      final map = doc.data() as Map;
      map.forEach((key, value) => _questList.add(MiniQuest.fromMap(key, value)));
      _initialised = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_initialised) return Center(child: CommonUtils.loadingIndicator());

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _searchBar(),
          const SizedBox(height: 20),
          Expanded(child: _questListContents()),
        ],
      ),
    );
  }

  Widget _searchBar() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 55,
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: TextField(
            autofocus: false,
            controller: _searchController,
            onChanged: (String text) {},
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: "Search Quest..",
              suffixIcon: Visibility(
                visible: _searchController.text.isNotEmpty,
                child: IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _questListContents() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: _questList.length,
          itemBuilder: (context, index) => _questCard(_questList[index], index),
        ),
      );

  Widget _questCard(MiniQuest quest, int index) => CachedUserData(
        key: Key(quest.id!),
        uid: quest.creator,
        builder: (user) => Material(
          child: InkWell(
            highlightColor: PeanutTheme.primaryColor.withOpacity(0.5),
            onTap: () => false,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: PeanutTheme.backGroundColor, width: 3))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonUtils.buildUserImage(context: context, user: user, size: 65),
                  const SizedBox(width: 15),
                  Flexible(fit: FlexFit.tight, child: _questDetails(quest, user)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _questDetails(MiniQuest quest, NutUser user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, color: PeanutTheme.primaryColor),
          ),
          Text(
            quest.title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: PeanutTheme.almostBlack, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  quest.mapModel!.addr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: PeanutTheme.grey),
                ),
              ),
            ],
          ),
        ],
      );
}
