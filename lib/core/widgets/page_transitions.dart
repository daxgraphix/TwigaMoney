import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// A page with smooth slide transition and edge-swipe-to-pop gesture.
/// Uses CupertinoPage for native iOS-style edge-drag back gesture on all platforms.
class SwipeToPopPage extends CupertinoPage<void> {
  const SwipeToPopPage({
    required LocalKey key,
    required Widget child,
    bool maintainState = true,
  }) : super(key: key, child: child, maintainState: maintainState);

  static Page<void> create(GoRouterState state, Widget child) {
    return SwipeToPopPage(
      key: state.pageKey,
      child: child,
    );
  }
}

/// A back button that respects the navigation context.
/// Only renders when there is a previous route to pop.
class BackButtonWidget extends StatelessWidget {
  final Color? color;
  final double iconSize;

  const BackButtonWidget({super.key, this.color, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    if (!context.canPop()) return const SizedBox.shrink();
    return IconButton(
      icon: Icon(Icons.chevron_left, size: iconSize + 4),
      color: color ?? Theme.of(context).primaryColor,
      onPressed: () => context.pop(),
    );
  }
}
