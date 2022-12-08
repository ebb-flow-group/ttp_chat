import 'package:flutter/material.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/widgets/br.dart';
import 'package:ttp_chat/core/widgets/empty.dart';

class OrderMessageBox extends StatelessWidget {
  final RichText? title;
  final RichText? subtitle;
  final List<Widget> actions;

  const OrderMessageBox({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width - 20 - 27,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          title ?? const Empty(),
          subtitle ?? const Empty(),
          if (actions.isNotEmpty) ...[
            const BR(10),
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: L.w(10),
              spacing: L.h(10),
              children: actions,
            ),
          ]
        ],
      ),
    );
  }
}
