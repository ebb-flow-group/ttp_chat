import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/core/widgets/triangle_painter.dart';
import 'package:ttp_chat/features/chat/domain/search_user_model.dart';
import 'package:ttp_chat/models/base_model.dart';
import 'package:ttp_chat/network/api_service.dart';
import 'package:ttp_chat/theme/style.dart';
import 'package:ttp_chat/utils/functions.dart';

class SearchUserScreen extends StatefulWidget {
  final String? accessToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const SearchUserScreen(
      {Key? key, this.accessToken, this.onViewOrderDetailsClick})
      : super(key: key);

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  List<Brands> brandsList = [];
  List<Users> usersList = [];
  int selectedTabIndex = 0;
  List<Map<String, dynamic>> userRooms = [];
  Map<String, dynamic> existedRoom = {};
  // types.User? user;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDFBEF).withOpacity(0.2),
          title: Text('Start a new chat',
              style: Theme.of(context).textTheme.headline6),
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
                brandsList.isNotEmpty || usersList.isNotEmpty
                    ? _tabs()
                    : const SizedBox(),
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
    BaseModel<SearchUserModel> response = await GetIt.I<ApiService>()
        .searchUser(widget.accessToken!, searchValue);

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
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: selectedTabIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400]),
                  ),
                  const SizedBox(width: 6),
                  count == 0
                      ? const SizedBox()
                      : Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12, height: 1),
                          ),
                        )
                ],
              ),
              const SizedBox(height: 2),
              selectedTabIndex == index
                  ? CustomPaint(
                      painter: TrianglePainter(
                        strokeColor: Theme.of(context).primaryColor,
                        paintingStyle: PaintingStyle.fill,
                      ),
                      child: const SizedBox(
                        height: 6,
                        width: 12,
                      ),
                    )
                  : const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget brandsListWidget() {
    return brandsList.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: brandsList.length,
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            itemBuilder: (context, index) {
              Brands brand = brandsList[index];
              return isLoggedInUser(brand.username)
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200]),
                            child: Icon(Icons.fastfood,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2))),
                        const SizedBox(width: 17),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      brand.name ?? "",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '@${brand.username}',
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (brand.username == null) {
                                    displaySnackBar(
                                        "Error, This user has no username",
                                        context);
                                    return;
                                  }
                                  bool exists =
                                      await checkExist(brand.username!);

                                  if (exists) {
                                    types.Room selectedRoom = types.Room(
                                      id: existedRoom['id'],
                                      type: types.RoomType.direct,
                                      name: existedRoom['name'],
                                      imageUrl: existedRoom['imageUrl'],
                                      userIds: existedRoom['userIds'],
                                      users: [],
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                            selectedRoom,
                                            false,
                                            widget.onViewOrderDetailsClick),
                                      ),
                                    );
                                  } else {
                                    types.User? user =
                                        await getUserFromFireStore(
                                      brand.username!,
                                      id: brand.username,
                                      firstName: brand.name,
                                    );
                                    if (user != null) {
                                      consoleLog(
                                          "Creating New Room for ${brand.username}");
                                      final room = await FirebaseChatCore
                                          .instance
                                          .createRoom(user);
                                      consoleLog(
                                          'Room Name: ${room.name} \nId: ${room.name} \nUsers: ${room.userIds}');
                                      types.Room selectedRoom = types.Room(
                                          id: room.id,
                                          type: types.RoomType.direct,
                                          name: room.name,
                                          imageUrl: room.imageUrl,
                                          userIds: room.userIds,
                                          users: room.users);
                                      userRooms.add({
                                        "userIds": room.userIds,
                                        "id": room.id,
                                        "name": room.name,
                                        "imageUrl": room.imageUrl,
                                      });
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              selectedRoom,
                                              false,
                                              widget.onViewOrderDetailsClick),
                                        ),
                                      );
                                    } else {
                                      displaySnackBar(
                                          "Error, User Not Found", context);
                                    }
                                  }
                                },
                                icon: SvgPicture.asset(
                                  'assets/chat_icons/chat.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
            },
            separatorBuilder: (context, index) {
              return isLoggedInUser(brandsList[index].username)
                  ? const SizedBox.shrink()
                  : const SizedBox(height: 17);
            },
          )
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/chat_icons/no_chat_user.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'No result',
                  style: appBarTitleStyle(context).copyWith(fontSize: 16),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
  }

  Widget usersListWidget() {
    return usersList.isNotEmpty
        ? ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: usersList.length,
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            itemBuilder: (context, index) {
              Users singleUser = usersList[index];
              return isLoggedInUser(singleUser.phoneNumber)
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.grey[200]),
                          child: Icon(Icons.person,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2)),
                        ),
                        const SizedBox(width: 17),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      singleUser.firstName != null &&
                                              singleUser.lastName != null
                                          ? '${singleUser.firstName!} ${singleUser.lastName!}'
                                          : 'Guest',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      singleUser.email != null
                                          ? singleUser.email!
                                          : singleUser.phoneNumber!,
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (singleUser.phoneNumber == null) {
                                    displaySnackBar(
                                        "Error, This user has no phone number",
                                        context);
                                    return;
                                  }

                                  bool exists = await checkExist(
                                      singleUser.phoneNumber ?? "");
                                  consoleLog('EXIST: $existedRoom $exists');
                                  if (exists) {
                                    types.Room selectedRoom = types.Room(
                                      id: existedRoom['id'],
                                      type: types.RoomType.direct,
                                      name: existedRoom['name'],
                                      imageUrl: existedRoom['imageUrl'],
                                      userIds: existedRoom['userIds'],
                                      users: [],
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                            selectedRoom,
                                            false,
                                            widget.onViewOrderDetailsClick),
                                      ),
                                    );
                                  } else {
                                    types.User? user =
                                        await getUserFromFireStore(
                                            singleUser.phoneNumber!,
                                            id: singleUser.phoneNumber,
                                            firstName: singleUser.firstName,
                                            lastName: singleUser.lastName);
                                    if (user != null) {
                                      consoleLog("Creating New Room");
                                      final room = await FirebaseChatCore
                                          .instance
                                          .createRoom(user);
                                      consoleLog(
                                          'Room Name: ${room.name} \nId: ${room.name} \nUsers: ${room.userIds}');
                                      types.Room selectedRoom = types.Room(
                                          id: room.id,
                                          type: types.RoomType.direct,
                                          name: room.name,
                                          imageUrl: room.imageUrl,
                                          userIds: room.userIds,
                                          users: room.users);
                                      userRooms.add({
                                        "userIds": room.userIds,
                                        "id": room.id,
                                        "name": room.name,
                                        "imageUrl": room.imageUrl,
                                      });
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              selectedRoom,
                                              false,
                                              widget.onViewOrderDetailsClick),
                                        ),
                                      );
                                    } else {
                                      displaySnackBar(
                                          "Error, User Not Found", context);
                                    }
                                  }
                                },
                                icon: SvgPicture.asset(
                                  'assets/chat_icons/chat.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
            },
            separatorBuilder: (context, index) {
              return isLoggedInUser(usersList[index].phoneNumber)
                  ? const SizedBox.shrink()
                  : const SizedBox(height: 17);
            },
          )
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/chat_icons/no_chat_user.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'No result',
                  style: appBarTitleStyle(context).copyWith(fontSize: 16),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
  }

  Future<bool> checkExist(String docId) async {
    try {
      if (userRooms.isNotEmpty) {
        consoleLog("checking from list");

        //?checking whether user is sending message to himself
        if (docId == FirebaseAuth.instance.currentUser?.uid) {
          log("Checking if user has room with himself");
          for (var room in userRooms) {
            var userIds = (room['userIds'] ?? []) as List<dynamic>;
            bool isUser = areItemsEqual(userIds);
            if (isUser) {
              consoleLog("User's Personal Room Found");
              existedRoom = room;
              existedRoom['id'] = room["id"];
              return true;
            }
          }
          return false;
        }
        for (var room in userRooms) {
          var userIds = (room['userIds'] ?? []) as List<dynamic>;
          if (userIds.contains(docId)) {
            log(userIds.toString());
            consoleLog('Room Exists $room');
            existedRoom = room;
            existedRoom['id'] = room["id"];
            return true;
          }
        }
        consoleLog("Room Doesn't Exist");
        return false;
      } else {
        consoleLog("checking from firestore");
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('rooms')
            .where('userIds',
                arrayContains: FirebaseAuth.instance.currentUser!.uid)
            // .where('userIds', arrayContains: docId)
            .get();
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            var data = doc.data() as Map<String, dynamic>;
            userRooms.add({
              "userIds": (data['userIds'] ?? []) as List<dynamic>,
              "id": doc.id,
              "name": data['name'],
              "imageUrl": data['imageUrl'],
            });
          }
          consoleLog(userRooms.toString());
          //Check Room Again
          consoleLog("Checking room again from List");
          return checkExist(docId);
        } else {
          //No Room Exists
          consoleLog("No Room Exists");
          return false;
        }
      }
    } catch (e) {
      // If any error
      print('CHECK EXISTS ERROR $e');
      return false;
    }
  }

  Future<types.User?> getUserFromFireStore(String userId,
      {String? firstName,
      String? id,
      String? imageUrl = "",
      String? lastName = ""}) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        types.User result = types.User(
          id: snapshot.id,
          firstName: data['firstName'],
          lastName: data['lastName'],
          imageUrl: data['imageUrl'],
        );
        return result;
      } else {
        if (id == null) {
          return null;
        }
        var user = types.User(
          firstName: firstName ?? "Guest",
          id: id,
          imageUrl: imageUrl ?? "",
          lastName: lastName ?? "",
        );
        consoleLog("Creating New User $firstName $lastName $id");

        await FirebaseChatCore.instance.createUserInFirestore(user);
        return user;
      }
    } catch (e) {
      // If any error
      print('GET USER ERROR $e');
      return null;
    }
  }
}
