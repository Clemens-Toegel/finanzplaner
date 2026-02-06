import 'package:flutter/material.dart';

class MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  MonthHeaderDelegate({required this.title});

  final String title;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant MonthHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}
