import 'package:flutter/material.dart';

import '../../../widgets/triangle_painter.dart';

class SearchTabBar extends StatelessWidget {
  const SearchTabBar(
      {Key? key, required this.selectedTabIndex, this.onTap, required this.count, required this.index, this.title = ""})
      : super(key: key);

  final int selectedTabIndex;
  final String title;
  final int count;
  final int index;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style:
                        TextStyle(color: selectedTabIndex == index ? Theme.of(context).primaryColor : Colors.grey[400]),
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
                            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1),
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
}
