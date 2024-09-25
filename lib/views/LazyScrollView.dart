// This code is for a custom scroll view in a Flutter application.
import 'package:flutter/material.dart';

class LazyScrollView extends StatelessWidget {
  final ScrollController scrollController = ScrollController();
  final OnScrollListener? onScrollListener;

  LazyScrollView({Key? key, this.onScrollListener}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) {
        Future.delayed(const Duration(milliseconds: 233), () {
          if (scrollController.position.maxScrollExtent <= scrollController.offset + MediaQuery.of(context).size.height) {
            onScrollListener?.onBottom();
          } else if (scrollController.offset == 0) {
            onScrollListener?.onTop();
          } else {
            onScrollListener?.onScroll();
          }
        });
      },
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Add your child widgets here
          ],
        ),
      ),
    );
  }
}

/**
 * Defines an interface for scroll events
 * @author admin
 */
abstract class OnScrollListener {
  void onBottom();
  void onTop();
  void onScroll();
}