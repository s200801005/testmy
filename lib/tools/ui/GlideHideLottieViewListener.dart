// This code is translated from Kotlin to Dart.
// It uses Flutter framework for UI elements.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GlideHideLottieViewListener extends RequestListener<Drawable> {
  final WeakReference<LottieAnimationView> weakLottieAnimationView;
  final VoidCallback? runAfterLoad;

  GlideHideLottieViewListener(this.weakLottieAnimationView, {this.runAfterLoad});

  @override
  bool onLoadFailed(GlideException? exception, dynamic model, Target<Drawable>? target, bool isFirstResource) {
    return false;
  }

  @override
  bool onResourceReady(Drawable resource, dynamic model, Target<Drawable>? target, DataSource dataSource, bool isFirstResource) {
    final lottieAnimationView = weakLottieAnimationView.get();
    lottieAnimationView?.pauseAnimation();
    lottieAnimationView?.visibility = View.GONE;
    runAfterLoad?.call();
    return false;
  }
}