import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeHandler {
  final WeakReference<HomeFragment> that;
  IndexStructure? index;
  Banner? fhib;
  List<Widget> indexLines = [];

  HomeHandler(this.that);

  void handleMessage(Message msg) {
    switch (msg.what) {
      case -1:
        that.value?.swiperefresh?.isRefreshing = msg.obj as bool;
        if (msg.obj as bool) {
          showKanban();
        } else {
          hideKanban();
        }
        break;
      case 1:
        inflateCardLines();
        break;
      case 2:
        that.value?.swiperefresh?.let((it) => setSwipe(it));
        break;
      case 3:
        setBanner(fhib!);
        break;
      case 5:
        setBannerInfo(msg.obj as Banner);
        break;
      case 6:
        that.value?.fhl?.let((it) {
          final oa = ObjectAnimator.ofFloat(it, "alpha", 1.0, 0.0).setDuration(233);
          oa.doOnEnd(() {
            it.removeAllViews();
            it.alpha = 1.0;
          });
          oa.start();
        });
        break;
      case 7:
        inflateBanner();
        break;
    }
  }

  IndexStructure? getGsonItem() => index;

  bool setGsonItem(dynamic gsonObj) {
    final pass = super.setGsonItem(gsonObj);
    index = gsonObj as IndexStructure;
    var banners = <IndexStructure.Results.Banners>[];
    index?.results?.banners?.forEach((it) {
      if (it.type == 1) {
        banners.add(it);
      }
    });
    index?.results?.banners = banners;
    return pass;
  }

  Future<void> onError() async {
    super.onError();
    if (exit) return;
    sendEmptyMessage(2); //setSwipe
    obtainMessage(-1, false).sendToTarget(); //closeLoad
    await Future.delayed(Duration(milliseconds: 200));
    ScaffoldMessenger.of(that.value!.context).showSnackBar(
      SnackBar(content: Text('Web error')),
    );
  }

  Future<void> doWhenFinishDownload() async {
    super.doWhenFinishDownload();
    if (exit) return;
    sendEmptyMessage(2); //setSwipe
    sendEmptyMessage(7); //inflateBanner
    sendEmptyMessage(1); //inflateCardLines
  }

  void inflateBanner() {
    that.value?.fhl?.addView(fhib!);
  }

  Future<void> inflateTopics() async {
    index?.results?.topics?.list?.let((it) {
      var comics = <ComicStructure>[];
      for (var i = 0; i < it.length; i++) {
        if (i > 2) break;
        final newComic = ComicStructure();
        newComic.name = it[i].title;
        newComic.cover = it[i].cover;
        newComic.path_word = it[i].path_word;
        comics.add(newComic);
      }
      if (comics.length == 3) {
        allocateLine(
          that.value?.getString('topics_series') ?? "",
          'img_hot_serial',
          comics,
          isTopic: true,
        );
      }
    });
  }

  Future<void> inflateRec() async {
    index?.results?.recComics?.list?.let((it) {
      var comics = <ComicStructure>[];
      for (var i = 0; i < it.length; i++) {
        if (i > 2) break;
        comics.add(it[i].comic);
      }
      if (comics.length == 3) {
        allocateLine(
          that.value?.getString('manga_rec') ?? "",
          'img_master_work',
          comics,
        ) {
          that.value?.findNavController()?.let((nav) {
            Navigate.safeNavigateTo(nav, 'action_nav_home_to_nav_recommend');
          });
        };
      }
    });
  }

  Future<void> inflateRank() async {
    var comics = <ComicStructure>[];
    index?.results?.rankDayComics?.list?.let((it) {
      for (var i = 0; i < it.length; i++) {
        if (i > 2) break;
        comics.add(it[i].comic);
      }
    });
    index?.results?.rankWeekComics?.list?.let((it) {
      for (var i = 0; i < it.length; i++) {
        if (i > 2) break;
        comics.add(it[i].comic);
      }
    });
    index?.results?.rankMonthComics?.list?.let((it) {
      for (var i = 0; i < it.length; i++) {
        if (i > 2) break;
        comics.add(it[i].comic);
      }
    });
    if (comics.length == 9) {
      allocateLine(
        that.value?.getString('rank_list') ?? "",
        'img_novel_bill',
        comics,
      ) {
        that.value?.findNavController()?.navigate('nav_rank');
      };
    }
  }

  Future<void> inflateHot() async {
    index?.results?.hotComics?.let((it) {
      var comics = <ComicStructure>[];
      for (var i = 0; i < it.length; i++) {
        if (i > 8) break;
        comics.add(it[i].comic);
      }
      if (comics.length == 9) {
        allocateLine(
          that.value?.getString('hot_list') ?? "",
          'img_hot',
          comics,
        );
      }
    });
  }

  Future<void> inflateNew() async {
    index?.results?.newComics?.let((it) {
      var comics = <ComicStructure>[];
      for (var i = 0; i < it.length; i++) {
        if (i > 8) break;
        comics.add(it[i].comic);
      }
      if (comics.length == 9) {
        allocateLine(
          that.value?.getString('new_list') ?? "",
          'img_latest_pub',
          comics,
        ) {
          that.value?.findNavController()?.let((nav) {
            Navigate.safeNavigateTo(nav, 'action_nav_home_to_nav_newest');
          });
        };
      }
    });
  }

  Future<void> inflateFinish() async {
    index?.results?.finishComics?.list?.let((it) {
      var comics = <ComicStructure>[];
      for (var i = 0; i < it.length; i++) {
        if (i > 5) break;
        comics.add(it[i]);
      }
      if (comics.length == 6) {
        allocateLine(
          that.value?.getString('complete') ?? "",
          'img_novel_eye',
          comics,
          true,
        ) {
          that.value?.findNavController()?.let((nav) {
            Navigate.safeNavigateTo(nav, 'action_nav_home_to_nav_finish');
          });
        };
      }
    });
  }

  void inflateCardLines() {
    that.value?.lifecycleScope?.launch(() async {
      await Future.delayed(Duration(milliseconds: 200));
      if (indexLines.isNotEmpty) indexLines = [];
      await inflateRec();
      await inflateTopics();
      await inflateHot();
      await inflateNew();
      await inflateFinish();
      await inflateRank();
      that.value?.fhl?.apply {
        post(() {
          for (var i = 0; i < indexLines.length; i++) {
            try {
              addView(indexLines[i]);
            } catch (e) {
              e.printStackTrace();
              (indexLines[i].parent as LinearLayout).apply {
                post(() {
                  removeAllViews();
                  that.value?.fhl?.addView(indexLines[i]);
                });
              };
            }
          }
          obtainMessage(-1, false).sendToTarget(); //closeLoad
        });
      }
    });
  }

  Banner setBanner(Banner v) {
    v.viewTreeObserver.addOnGlobalLayoutListener(() {
      v.layoutParams.height = (v.width / 1.875 + 0.5).toInt();
      v.invalidate();
      v.viewTreeObserver.removeOnGlobalLayoutListener(this);
    });
    obtainMessage(5, v).sendToTarget(); //setBannerInfo
    return v;
  }

  void setBannerInfo(Banner v) {
    that.value?.context?.let((it) {
      UITools(it).let((uiTools) {
        v
          .addPageTransformer(ScaleInTransformer())
          .setPageMargin(uiTools.dp2px(20) ?? 0, uiTools.dp2px(10) ?? 0)
          .setIndicator(
            IndicatorView(that.value!.context)
              .setIndicatorColor(Color.DKGRAY)
              .setIndicatorSelectorColor(Color.WHITE)
              .setIndicatorStyle(IndicatorView.IndicatorStyle.INDICATOR_BEZIER),
          )
          .adapter = that.value?.ViewData(v)?.RecyclerViewAdapter;
      });
    });
    v.invalidate();
  }

  void setSwipe(SwipeRefreshLayout sw) {
    that.value?.fhov?.swipeRefreshLayout = sw;
    sw.setOnRefreshListener(() {
      that.value?.lifecycleScope?.launch(() async {
        await Future.delayed(Duration(milliseconds: 200));
        that.value?.showKanban();
        fhib?.isAutoPlay = false;
        index = null;
        fhib?.adapter?.notifyDataSetChanged();
        fhib = null;
        indexLines = [];
        this.sendEmptyMessage(6); //removeAllViews
        await Future.delayed(Duration(milliseconds: 300));
        this.sendEmptyMessage(0); //setLayouts
      });
    });
  }

  Future<int> allocateLine(
    String title,
    String iconResId,
    List<ComicStructure> comics, {
    bool finish = false,
    bool isTopic = false,
    VoidCallback? onClick,
  }) async {
    final p = indexLines.length;
    final c = comics.length ~/ 3;
    that.value?.layoutInflater?.inflate(
      c == 1
          ? 'line_1bookline'
          : c == 2
              ? 'line_2bookline'
              : c == 3
                  ? 'line_3bookline'
                  : return -1,
      null,
      false,
    )?.apply((v) {
      scanCards(v, comics, finish, isTopic);
      post(() {
        v.rttitle.text = title;
        v.ir.setImageResource(iconResId);
        setLineHeight(v, c);
        if (onClick != null) v.setOnClickListener(() => onClick());
      });
      indexLines.add(v);
    });
    return p;
  }

  Future<void> scanCards(View v, List<ComicStructure> comics, bool finish, bool isTopic) async {
    var id = v.rc1.id;
    var card = v.findViewById<ConstraintLayout>(id);
    for (var data in comics) {
      setCards(
        card.cic,
        data.path_word,
        data.name,
        data.cover,
        finish,
        isTopic,
      );
      card = v.findViewById(++id);
    }
  }

  var cardLoadingWaits = AtomicInteger();

  void setCards(CardView cv, String pw, String name, String img, bool isFinal, bool isTopic) {
    cv.tic.apply {
      post(() {
        text = name;
      });
    };
    that.value?.let((it) {
      if (img.startsWith("http")) {
        final waitMillis = cardLoadingWaits.getAndIncrement().toLong() * 200;
        final g = Glide.with(it).load(GlideUrl(CMApi.imageProxy?.wrap(img) ?? img, CMApi.myGlideHeaders))
          .addListener(GlideHideLottieViewListener(WeakReference(cv.laic)) {
            cardLoadingWaits.decrementAndGet();
          })
          .timeout(60000);
        if (waitMillis > 0) {
          cv.imic.postDelayed(() {
            g.into(cv.imic);
          }, waitMillis);
        } else {
          cv.imic.post(() {
            g.into(cv.imic);
          });
        }
      }
    });
    if (isFinal) {
      cv.sgnic.apply {
        post(() {
          visibility = View.VISIBLE;
        });
      };
    }
    cv.post(() {
      cv.setOnClickListener(() {
        final bundle = Bundle();
        bundle.putString("path", pw);
        that.value?.findNavController()?.let((nav) {
          Navigate.safeNavigateTo(nav, isTopic ? 'action_nav_home_to_nav_topic' : 'action_nav_home_to_nav_book', bundle);
        });
      });
    });
  }

  void setLineHeight(View v, int cardCount) {
    v.viewTreeObserver.addOnGlobalLayoutListener(() {
      that.value?.context?.let((it) {
        UITools(it).let((uiTools) {
          final spaceTitle = uiTools.dp2px(49) ?? 0;
          final cardSpace = uiTools.dp2px(16) ?? 0;
          v.layoutParams.height =
              ((v.width - cardSpace * 3) * cardCount * 4.0 / 9.0 + spaceTitle + cardSpace * cardCount + 0.5).toInt();
          v.invalidate();
          v.viewTreeObserver.removeOnGlobalLayoutListener(this);
        });
      });
    });
  }
}

