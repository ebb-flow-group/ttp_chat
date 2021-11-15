import 'package:flutter/material.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen>
    with SingleTickerProviderStateMixin {

  late TabController tabController;
  int tabIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Activity',
          style: Ts.bold24(Config.primaryColor),
        ),
        centerTitle: false,
      ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              _wSearch()
            ],
          ),
        ));
  }

  Widget _wSearch() {
    return InputSearch(
      hintText: L.t('Search user...'),
      onChanged: (String value){},
    );
  }

  Widget _tabs() {
    return TabBar(
      controller: tabController,
      indicatorColor: Colors.transparent,

      onTap: (n) {
        setState(() {
          tabIndex = n;
        });
      },
      // indicator: ,
      tabs: [
        Tab(
            child: Text(
              'New Orders(2)',
              style: TextStyle(
                  color: tabIndex == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor.withOpacity(0.7),
                  fontWeight: FontWeight.w600
              ),
            )
        ),
        Tab(
            child: Text(
              'Orders in Progress (3)',
              style: TextStyle(
                  color: tabIndex == 1
                      ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor.withOpacity(0.7),
                  fontWeight: FontWeight.w600
              ),
            )
        ),
      ],
    );
  }
}
