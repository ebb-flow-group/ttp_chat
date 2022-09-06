import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/widgets/no_search_results.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../features/chat/domain/search_user_model.dart';
import '../../../models/base_model.dart';
import '../../../network/api_service.dart';
import '../../../packages/chat_core/src/util.dart';
import '../../../utils/functions.dart';
import '../../services/routes.dart';
import '../../services/ts.dart';
import '../../widgets/input_search.dart';
import '../widgets/helpers.dart';
import 'search_widgets/search_user_tile.dart';

class SearchPage extends StatefulWidget {
  final String? accessToken;

  const SearchPage({Key? key, this.accessToken}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<SearchUser> users = [];
  List<types.Room> userRooms = [];
  bool searching = false;
  Timer? _debounce;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //added the pagination function with listener
    scrollController.addListener(pagination);
    searchUser();
  }

  void pagination() {
    if ((scrollController.position.pixels == scrollController.position.maxScrollExtent)) {
      searchUser(paginate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Start a new chat', style: Ts.bold17(Config.primaryColor)),
          actions: [
            if (searching)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Center(
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 4,
                    ),
                  ),
                ),
              )
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 17.0),
                child: InputSearch(
                    controller: searchController,
                    autofocus: true,
                    hintText: 'Search a brand, user or mobile',
                    onChanged: (String value) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        searchUser();
                      });
                    }),
              ),
              const SizedBox(height: 10),
              // users.isEmpty
              //     ? const Text(
              //         'Search for someone on Tabletop',
              //         style: TextStyle(
              //           color: Colors.grey,
              //           fontSize: 14,
              //           fontWeight: FontWeight.w400,
              //         ),
              //         softWrap: true,
              //         textAlign: TextAlign.center,
              //       )
              //     : const SizedBox(),
              Expanded(
                  child: users.isEmpty && !searching
                      ? const NoResults()
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: users.length,
                          padding: const EdgeInsets.symmetric(horizontal: 17.0),
                          itemBuilder: (BuildContext ctx, int index) {
                            SearchUser user = users[index];
                            return SearchUserTile(
                              user,
                              onChatClick: () {
                                hideKeyboard(context);
                                if (user.uid == null) {
                                  displaySnackBar(
                                      "This user isn’t enabled for chat. You could reach out to Tabletop Support for assistance.",
                                      context);
                                  return;
                                }
                                context.push(
                                    RouteParser(Routes.chatUserRoute).reverse({'id': Uri.encodeComponent(user.uid!)}));
                              },
                            );
                          })),
              if (searching && users.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 4,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ));
  }

  void searchUser({bool paginate = false}) async {
    if (searching) return;
    setState(() {
      searching = true;
    });
    try {
      BaseModel<SearchUserModel> response = await ApiService()
          .searchUser(widget.accessToken!, searchController.text, offset: paginate ? users.length : 0);
      if (response.data != null) {
        searching = false;
        paginate ? users.addAll(response.data?.users ?? []) : users = response.data?.users ?? [];
      }
    } finally {
      searching = false;
      setState(() {});
    }
  }

  // Widget _tab(int index, String title, int count) {
  //   return SearchTabBar(
  //       selectedTabIndex: selectedTabIndex,
  //       index: index,
  //       title: title,
  //       count: count,
  //       onTap: () => setState(() => selectedTabIndex = index));
  // }

  Future<types.Room?> checkExist(
    String docId,
  ) async {
    try {
      if (userRooms.isNotEmpty) {
        consoleLog("checking from list");
        //?checking whether user is sending message to himself
        if (docId == FirebaseAuth.instance.currentUser?.uid) {
          consoleLog("Checking if user has room with himself");
          for (var room in userRooms) {
            bool isUser = areItemsEqual(room.userIds);
            if (isUser) {
              consoleLog("User's Personal Room Found");
              return room;
            }
          }
          return null;
        }
        for (var room in userRooms) {
          if (room.userIds.contains(docId)) {
            consoleLog(room.userIds.toString());
            consoleLog('Room Exists $room');
            return room;
          }
        }
        consoleLog("Room Doesn't Exist");
        return null;
      } else {
        consoleLog("checking from firestore");
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('rooms')
            .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (snapshot.docs.isNotEmpty) {
          List<types.Room> rooms = await processRoomsQuery(FirebaseAuth.instance.currentUser!, snapshot);
          //removing rooms that are group or channels
          rooms.removeWhere(
              (element) => (element.type == types.RoomType.channel || element.type == types.RoomType.group));
          userRooms.addAll(rooms);
          consoleLog(userRooms.toString());
          //Check Room Again
          consoleLog("Checking room again from List");
          return checkExist(docId);
        } else {
          //No Room Exists
          consoleLog("No Room Exists");
          return null;
        }
      }
    } catch (e) {
      // If any error
      consoleLog('CHECK EXISTS ERROR $e');
      return null;
    }
  }
}
