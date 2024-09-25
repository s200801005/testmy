import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_glide/flutter_glide.dart';
import 'package:flutter_glide/glide_request_listener.dart';
import 'package:flutter_glide/glide_request_options.dart';
import 'package:flutter_glide/glide_target.dart';
import 'package:flutter_glide/glide_url.dart';
import 'package:flutter_glide/glide_exception.dart';
import 'package:flutter_glide/glide_drawable.dart';
import 'package:flutter_glide/glide_data_source.dart';
import 'package:flutter_glide/glide_headers.dart';
import 'package:flutter_glide/glide_blur_transformation.dart';
import 'package:flutter_glide/glide_hide_lottie_view_listener.dart';
import 'package:flutter_glide/glide_navigation.dart';
import 'package:flutter_glide/glide_reader.dart';
import 'package:flutter_glide/glide_api.dart';
import 'package:flutter_glide/glide_theme_structure.dart';
import 'package:flutter_glide/glide_book_fragment.dart';
import 'package:flutter_glide/glide_navigate.dart';
import 'package:flutter_glide/glide_tab_layout_mediator.dart';
import 'package:flutter_glide/glide_recycler_view_adapter.dart';
import 'package:flutter_glide/glide_nested_scroll_view.dart';
import 'package:flutter_glide/glide_linear_layout.dart';
import 'package:flutter_glide/glide_text_view.dart';
import 'package:flutter_glide/glide_view.dart';
import 'package:flutter_glide/glide_view_group.dart';
import 'package:flutter_glide/glide_bundle.dart';
import 'package:flutter_glide/glide_log.dart';
import 'package:flutter_glide/glide_lifecycle_scope.dart';
import 'package:flutter_glide/glide_dispatchers.dart';
import 'package:flutter_glide/glide_delay.dart';
import 'package:flutter_glide/glide_launch.dart';
import 'package:flutter_glide/glide_with_context.dart';
import 'package:flutter_glide/glide_weak_reference.dart';

import '../../manga/Reader.dart';
import 'BookFragment.dart';

class BookHandler {
  final WeakReference<BookFragment> th;
  bool complete = false;
  List<String> chapterNames = [];
  int collect = -1;
  List<String> urlArray = [];
  List<String> uuidArray = [];
  bool exit = false;

  BookHandler(this.th);

  void handleMessage(Message msg) {
    switch (msg.what) {
      case 1:
        setCover();
        break;
      case 2:
        setTexts();
        break;
      case 3:
        setAuthorsAndTags();
        break;
      case 6:
        if (complete) {
          th.get()?.navigate2dl();
        }
        break;
      case 9:
        endSetLayouts();
        break;
      case 10:
        setVolumes();
        break;
    }
  }

  void endSetLayouts() {
    if (exit) return;
    th.get()?.fbloading?.apply((fbloading) {
      fbloading.pauseAnimation();
      fbloading.visibility = View.GONE;
    });
    complete = true;
    th.get()?.setStartRead();
    th.get()?.setAddToShelf();
    Log.d("MyBH", "Set complete: true");
  }

  void setCover() {
    if (exit) return;
    th.get()?.apply((that) {
      Glide.with(that).load(
      book?.cover != null
      ? GlideUrl(CMApi.imageProxy?.wrap(book?.cover!) ?? book?.cover!, CMApi.myGlideHeaders)
          : book?.cachedCover,
      ).timeout(60000).addListener(GlideHideLottieViewListener(WeakReference(that.laic))).addListener(
      GlideRequestListener<GlideDrawable>(
      onLoadFailed: (e, model, target, isFirstResource) {
      return false;
      },
      onResourceReady: (resource, model, target, dataSource, isFirstResource) {
      GlideBlurTransformation(that.context!).let((it2) {
      GlideRequestOptions.bitmapTransform(it2).let((it3) {
      Glide.with(that).load(resource).apply(it3).into(that.lbibg);
      });
      });
      return false;
      },
      ),
      ).into(that.imic);
    });
  }

  void setTexts() {
    if (exit) return;
    th.get()?.apply((that) {
      that.activity?.toolbar?.title = book?.name;
      that.btauth?.text = that.getString(R.string.text_format_region).format(book?.region ?? "未知");
      that.bttag?.text = that.getString(R.string.text_format_img_type).format(book?.imageType ?? "未知");
      that.bthit?.text = that.getString(R.string.text_format_hit).format(book?.popular ?? -1);
      that.btsub?.text = that.getString(R.string.text_format_stat).format(book?.status ?? "未知");
      that.bttime?.text = book?.updateTime ?? "未知";
      final v = that.layoutInflater.inflate(R.layout.line_text_info, that.lbl, false);
      (v as TextView).text = book?.brief;
      that.lbl?.addView(v);
      that.lbl?.addView(that.divider);
    });
  }

  void setTheme(String caption, List<ThemeStructure> themeStructure, int nav) {
    th.get()?.apply((that) {
      final t = that.layoutInflater.inflate(R.layout.line_caption, that.lbl, false);
      t.tcptn.text = caption;
      that.lbl.addView(t);
      that.lbl.addView(that.layoutInflater.inflate(R.layout.div_h, that.lbl, false));
    });
    View? line;
    final last = themeStructure.length - 1;
    for (int i = 0; i < themeStructure.length; i++) {
      final it = themeStructure[i];
      if (line == null) {
        if (i == last) {
          line = th.get()?.layoutInflater?.inflate(R.layout.line_chapter, th.get()!.lbl, false);
          line?.lcc?.apply((lcc) {
            lcc.lct.text = it.name;
            lcc.lci.setBackgroundResource(R.drawable.ic_list);
            lcc.setOnClickListener((_) {
              loadVolume(it.name, it.path_word, nav);
            });
          });
          th.get()?.lbl?.addView(line);
        } else {
          line = th.get()?.layoutInflater?.inflate(R.layout.line_2chapters, th.get()!.lbl, false);
          line?.l2cl?.apply((l2cl) {
            l2cl.lct.text = it.name;
            l2cl.lci.setBackgroundResource(R.drawable.ic_list);
            l2cl.setOnClickListener((_) {
              loadVolume(it.name, it.path_word, nav);
            });
          });
        }
      } else {
        line?.l2cr?.apply((l2cr) {
          l2cr.lct.text = it.name;
          l2cr.lci.setBackgroundResource(R.drawable.ic_list);
          l2cr.setOnClickListener((_) {
            loadVolume(it.name, it.path_word, nav);
          });
          th.get()?.lbl?.addView(line);
          line = null;
        });
      }
    }
  }

  void setAuthorsAndTags() {
    if (exit) return;
    th.get()?.apply((that) {
      book?.apply((book) {
        book.author?.let((it) {
          setTheme(
            that.getString(R.string.author),
            it,
            R.id.action_nav_book_to_nav_author,
          );
        });
        that.lbl.addView(that.layoutInflater.inflate(R.layout.div_h, that.lbl, false));
        book.theme?.let((it) {
          setTheme(
            that.getString(R.string.caption),
            it,
            R.id.action_nav_book_to_nav_caption,
          );
        });
      });
    });
  }

  Future<void> addVolumesView(LinearLayout l, View v) async {
    await withContext(Dispatchers.main, () {
      l.addView(v);
    });
  }

  Future<void> setVolume(LinearLayout fbl, int p) async {
    if (exit) return;
    th.get()?.apply((that) {
      book?.apply((book) {
        var i = 0;
        for (int j = 0; j < p; j++) {
          i += book.volumes[j].results?.list?.length ?? 0;
        }
        var last = i - 1;
        final comicName = book.name ?? return;
        book.volumes[p].let((v) {
        if (exit) return;
        View? line;
        last += v.results.list.length;
        for (final it in v.results.list) {
        final f = CMApi.getZipFile(that.context?.getExternalFilesDir(""), comicName, book.keys[p], it.name);
        that.isOnPause?.let((isOnPause) {
        while (isOnPause && !exit) {
        await delay(500);
        if (exit) return;
        }
        }) ?? return;
        if (line == null) {
        if (i == last) {
        line = that.layoutInflater.inflate(R.layout.line_chapter, fbl, false);
        line?.lcc?.apply((lcc) {
        lcc.lct.text = it.name;
        if (f.existsSync()) lcc.lci.setBackgroundResource(R.drawable.ic_success);
        Log.d("MyBH", "add last single chapter ${it.name}");
        final index = i;
        lcc.setOnClickListener((_) {
        Reader.start2viewManga(comicName, index, urlArray, uuidArray);
        });
        });
        line?.let((l) {
        await addVolumesView(fbl, l);
        });
        } else {
        line = that.layoutInflater.inflate(R.layout.line_2chapters, fbl, false);
        line?.l2cl?.apply((l2cl) {
        l2cl.lct.text = it.name;
        if (f.existsSync()) l2cl.lci.setBackgroundResource(R.drawable.ic_success);
        final index = i;
        l2cl.setOnClickListener((_) {
        Reader.start2viewManga(comicName, index, urlArray, uuidArray);
        });
        });
        }
        } else {
        line?.l2cr?.apply((l2cr) {
        l2cr.lct.text = it.name;
        if (f.existsSync()) l2cr.lci.setBackgroundResource(R.drawable.ic_success);
        final index = i;
        l2cr.setOnClickListener((_) {
        Reader.start2viewManga(comicName, index, urlArray, uuidArray);
        });
        line?.let((l) {
        await addVolumesView(fbl, l);
        });
        line = null;
        });
        }
        i++;
        }
        });
      });
    });
  }

  Future<void> setViewManga() async {
    if (exit) return;
    th.get()?.apply((that) {
      book?.apply((book) {
        final comicName = book.name ?? return;
        Reader.fileArray = [];
        urlArray = [];
        uuidArray = [];
        var i = 0;
        var last = -1;
        for (int groupIndex = 0; groupIndex < book.volumes.length; groupIndex++) {
        if (exit) return;
        final v = book.volumes[groupIndex];
        last += v.results.list.length;
        for (final it in v.results.list) {
        urlArray.add(CMApi.getChapterInfoApiUrl(book.path, it.uuid) ?? "");
        final f = CMApi.getZipFile(that.context?.getExternalFilesDir(""), comicName, book.keys[groupIndex], it.name);
        Reader.fileArray.add(f);
        chapterNames.add(it.name);
        uuidArray.add(it.uuid);
        that.isOnPause?.let((isOnPause) {
        while (isOnPause && !exit) {
        await delay(500);
        if (exit) return;
        }
        }) ?? return;
        i++;
        }
        }
      });
    });
    sendEmptyMessage(9);
  }

  void loadVolume(String name, String path, int nav) {
    if (complete) {
      Log.d("MyBH", "start to load chapter");
      final bundle = Bundle();
      bundle.putString("name", name);
      bundle.putString("path", path);
      th.get()?.apply((that) {
        Navigate.safeNavigateTo(that.findNavController(), nav, bundle);
      });
    }
  }

  void setVolumes() {
    th.get()?.apply((that) {
      that.fbtab?.let((tab) {
        that.fbvp?.let((vp) {
          vp.adapter = ViewData(vp).RecyclerViewAdapter();
          TabLayoutMediator(tab, vp, (t, p) {
            t.text = book?.keys?.elementAt(p);
          }).attach();
        });
      });
      that.lifecycleScope.launch(() {
        setViewManga();
      });
    });
  }

  class ViewData extends RecyclerView.ViewHolder {
  ViewData(View itemView) : super(itemView);

  class RecyclerViewAdapter extends RecyclerView.Adapter<ViewData> {
  @override
  ViewData onCreateViewHolder(ViewGroup parent, int viewType) {
  return ViewData(th.get()?.layoutInflater?.inflate(R.layout.page_nested_list, parent, false) as NestedScrollView);
  }

  @override
  void onBindViewHolder(ViewData holder, int position) {
  th.get()?.lifecycleScope?.launch(() {
  setVolume(holder.itemView.fbl, position);
  });
  }

  @override
  int getItemCount() => th.get()?.book?.keys?.length ?? 0;
  }
  }
}

