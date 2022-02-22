import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../features/chat/domain/search_user_model.dart';
import '../../../models/base_model.dart';
import '../../../network/api_service.dart';
import '../../../packages/chat_core/src/firebase_chat_core.dart';
import '../../../utils/functions.dart';
import '../../widgets/input_search.dart';
import '../chat_page/chat_page.dart';
import 'search_widgets/search_brand_tile.dart';
import 'search_widgets/search_list_view.dart';
import 'search_widgets/search_tab_bar.dart';
import 'search_widgets/search_user_tile.dart';

class SearchPage extends StatefulWidget {
  final String? accessToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const SearchPage({Key? key, this.accessToken, this.onViewOrderDetailsClick}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Brands> brandsList = [];
  List<Users> usersList = [];
  int selectedTabIndex = 0;
  List<types.Room> userRooms = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDFBEF).withOpacity(0.2),
          title: Text('Start a new chat', style: Theme.of(context).textTheme.headline6),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const SizedBox(height: 17),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: InputSearch(
                      hintText: 'Search a brand, user or mobile',
                      onChanged: (String value) {
                        searchUser(value);
                      }),
                ),
                const SizedBox(height: 20),
                brandsList.isEmpty && usersList.isEmpty
                    ? const Text(
                        'Search for someone on Tabletop',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox(),
                brandsList.isNotEmpty || usersList.isNotEmpty ? _tabs() : const SizedBox(),
                brandsList.isNotEmpty || usersList.isNotEmpty
                    ? selectedTabIndex == 0
                        ? brandsListWidget()
                        : usersListWidget()
                    : const SizedBox(),
                const SizedBox(height: 17),
              ],
            ),
          ),
        ));
  }

  void searchUser(String searchValue) async {
    BaseModel<SearchUserModel> response = await GetIt.I<ApiService>().searchUser(widget.accessToken!, searchValue);
    if (response.data != null) {
      setState(() {
        brandsList.clear();
        usersList.clear();
        brandsList.addAll(response.data!.brands!);
        usersList.addAll(response.data!.users!);

        if (brandsList.isEmpty) {
          setState(() {
            selectedTabIndex = 1;
          });
        }

        if (usersList.isEmpty) {
          setState(() {
            selectedTabIndex = 0;
          });
        }
      });
    }
  }

  Widget _tabs() {
    return Column(
      children: [
        const SizedBox(height: 17),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tab(0, 'Brands', brandsList.length),
            _tab(1, 'People', usersList.length),
          ],
        ),
        Container(
          height: 3,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 17),
      ],
    );
  }

  Widget _tab(int index, String title, int count) {
    return SearchTabBar(
        selectedTabIndex: selectedTabIndex,
        index: index,
        title: title,
        count: count,
        onTap: () => setState(() => selectedTabIndex = index));
  }

  Widget brandsListWidget() {
    return SearchListView(
        list: brandsList,
        itemBuilder: (context, index) {
          Brands brand = brandsList[index];
          return SearchBrandTile(
            brand: brand,
            onChatClick: () async {
              if (brand.username == null) {
                displaySnackBar("Error, This user has no username", context);
                return;
              }
              types.Room? chatRoom = await checkExist(brand.username!);
              if (chatRoom != null) {
                pushTo(ChatPage(chatRoom, widget.onViewOrderDetailsClick), context);
              } else {
                types.User? user = await getUserFromFireStore(
                  brand.username!,
                  firstName: brand.name,
                );
                if (user != null) {
                  consoleLog("Creating New Room for ${brand.username}");
                  final room = await FirebaseChatCore.instance.createRoom(user);
                  consoleLog('Room Name: ${room.name} \nId: ${room.name} \nUsers: ${room.userIds}');
                  userRooms.add(room);
                  pushTo(ChatPage(room, widget.onViewOrderDetailsClick), context);
                } else {
                  displaySnackBar("Error, User Not Found", context);
                }
              }
            },
          );
        });
  }

  Widget usersListWidget() {
    return SearchListView(
      list: usersList,
      itemBuilder: (context, index) {
        Users singleUser = usersList[index];
        return SearchUserTile(
          singleUser: singleUser,
          onChatClick: () async {
            if (singleUser.phoneNumber == null) {
              displaySnackBar("Error, This user has no phone number", context);
              return;
            }
            types.Room? chatRoom = await checkExist(singleUser.phoneNumber!);
            if (chatRoom != null) {
              pushTo(ChatPage(chatRoom, widget.onViewOrderDetailsClick), context);
            } else {
              types.User? user = await getUserFromFireStore(singleUser.phoneNumber!,
                  firstName: singleUser.firstName, lastName: singleUser.lastName);
              if (user != null) {
                consoleLog("Creating New Room");
                final room = await FirebaseChatCore.instance.createRoom(user);
                consoleLog('Room Name: ${room.name} \nId: ${room.name} \nUsers: ${room.userIds}');
                userRooms.add(room);
                pushTo(ChatPage(room, widget.onViewOrderDetailsClick), context);
              } else {
                displaySnackBar("Error, User Not Found", context);
              }
            }
          },
        );
      },
    );
  }

  Future<types.Room?> checkExist(
    String docId,
  ) async {
    try {
      if (userRooms.isNotEmpty) {
        consoleLog("checking from list");
        //?checking whether user is sending message to himself
        if (docId == FirebaseAuth.instance.currentUser?.uid) {
          log("Checking if user has room with himself");
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
            log(room.userIds.toString());
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
          for (var doc in snapshot.docs) {
            var data = doc.data() as Map<String, dynamic>;
            userRooms.add(types.Room(
              id: doc.id,
              type: types.RoomType.direct,
              name: data['name'],
              imageUrl: data['imageUrl'],
              userIds: data['userIds'] ?? [],
              users: const [],
            ));
          }
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
