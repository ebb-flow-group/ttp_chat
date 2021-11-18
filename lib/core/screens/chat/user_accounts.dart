import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ttp_chat/core/screens/chat/chat_design.dart';
import 'package:ttp_chat/features/chat/domain/chat_sign_in_model.dart';
import 'package:ttp_chat/theme/style.dart';

class UserAccounts extends StatefulWidget {
  final List<BrandChatFirebaseTokenResponse> brandCustomTokensList;

  UserAccounts(this.brandCustomTokensList);

  @override
  _UserAccountsState createState() => _UserAccountsState();
}

class _UserAccountsState extends State<UserAccounts> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('BRAND TOKEN LIST: ${widget.brandCustomTokensList[0].brandName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(
              Icons.person_search_rounded,
            ),
          ),
          centerTitle: false,
          titleSpacing: 1,
          title: Text(
            'Brands',
            style: appBarTitleStyle(context),
          ),
          actions: [
            IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/chat_search.svg',
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: (){}),
          ],
        ),
        body: ListView.separated(
          itemCount: widget.brandCustomTokensList.length,
          separatorBuilder: (_, __) {
            return const Divider(color: Colors.grey);
          },
          itemBuilder: (context, index){
            return ListTile(
              onTap: (){

                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatDesigns(
                      isSwitchedAccount: true,
                        brandFirebaseTokenResponse: widget.brandCustomTokensList[index])));
              },
              title: Text(
                  widget.brandCustomTokensList[index].brandName!
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        ));
  }
}
