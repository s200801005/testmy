import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookFragment extends StatefulWidget {
  @override
  _BookFragmentState createState() => _BookFragmentState();
}

class _BookFragmentState extends State<BookFragment> {
  bool isOnPause = false;
  Book? book;
  BookHandler? mBookHandler;

  @override
  void initState() {
    super.initState();
    ComicDlFragment.exit = false;
    fbvp?.setPadding(0, 0, 0, navBarHeight);

    if (isFirstInflate) {
      prepareHandler();
      try {
        book?.updateInfo();
      } catch (e) {
        print(e);
        if (mBookHandler?.exit != false) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('null_book')),
        );
        Navigator.of(context).pop();
        return;
      }
      print("read path: ${book?.path}");
      for (int i = 1; i <= 3; i++) {
        mBookHandler?.sendEmptyMessageDelayed(i, (i * 100).toInt());
      }
      try {
        book?.updateVolumes(() {
          Future.delayed(Duration(milliseconds: 300), () {
            mBookHandler?.sendEmptyMessage(10);
          });
        });
      } catch (e) {
        print(e);
        if (mBookHandler?.exit != false) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('null_volume')),
        );
        Navigator.of(context).pop();
        return;
      }
    } else {
      bookHandler.set(mBookHandler);
    }
  }

  @override
  void dispose() {
    super.dispose();
    mBookHandler?.exit = true;
    book?.exit = true;
    bookHandler.set(null);
  }

  void setStartRead() {
    if (mBookHandler?.chapterNames?.isNotEmpty == true) {
      setState(() {
        book?.name?.let((name) {
          getPreferences().getInt(name, -1).let((p) {
            this.lbbstart.apply((_) {
              var i = 0;
              if (p >= 0) {
                text = mBookHandler!!.chapterNames[p];
                i = p;
              }
              setOnClickListener(() {
                mBookHandler?.apply((_) {
                  Reader.start2viewManga(name, i, urlArray, uuidArray);
                });
              });
            });
          });
        });
      });
    }
  }

  Future<void> prepareHandler() async {
    arguments?.apply((_) {
      if (getBoolean("loadJson")) {
        getString("name")?.let((name) {
          try {
            book = Book(name, () {
              return getString(it);
            }, await getExternalFilesDir(""));
          } catch (e) {
          print(e);
          setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('null_book')),
          );
          Navigator.of(context).pop();
          });
          return;
          }
        });
      } else {
        getString("path").let((it) {
          if (it != null) {
            book = Book(it, (id) {
              return getString(id);
            }, await getExternalFilesDir(""), false);
          } else {
          setState(() {
          Navigator.of(context).pop();
          });
          return;
          }
        });
      }
    });
    setState(() {
      mBookHandler = BookHandler(WeakReference(this));
      bookHandler.set(mBookHandler);
    });
  }

  Future<void> queryCollect() async {
    MainActivity.shelf?.query(book?.path!)?.let((b) {
      mBookHandler?.collect = b.results?.collect ?? -2;
      print("get collect of ${book?.path} = ${mBookHandler?.collect}");
      tic.text = b.results?.browse?.chapter_name?.let((name) {
        return 'text_format_cloud_read_to'.format(name);
      });
    });
  }

  void setAddToShelf() {
    if (mBookHandler?.chapterNames?.isNotEmpty != true) return;
    queryCollect().then((_) {
      mBookHandler?.collect?.let((collect) {
        if (collect > 0) {
          setState(() {
            this.lbbsub.setText('button_sub_subscribed');
          });
        }
      });
      book?.uuid?.let((uuid) {
        this.lbbsub.setOnClickListener(() {
          if (this.lbbsub.text != 'button_sub') {
            mBookHandler?.collect?.let((collect) {
              if (collect < 0) return;
              val re = MainActivity.shelf?.del(collect);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(re)),
              );
              if (re == "请求成功") {
                setState(() {
                  this.lbbsub.setText('button_sub');
                });
              }
            });
            return;
          }
          val re = MainActivity.shelf?.add(uuid);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(re)),
          );
          if (re == "修改成功") {
            queryCollect();
            setState(() {
              this.lbbsub.setText('button_sub_subscribed');
            });
          }
        });
      });
    });
  }

  void navigate2dl() {
    final bundle = Bundle();
    print("nav2: ${arguments?.getString("path") ?? "null"}");
    bundle.putString("path", arguments?.getString("path") ?? "null");
    bundle.putString("name", book!!.name!!);
    if (book?.volumes != null && book?.json != null) {
      bundle.putString("loadJson", book!!.json);
    }
    findNavController().let((it) {
      Navigate.safeNavigateTo(it, R.id.action_nav_book_to_nav_group, bundle);
    });
  }

  static var bookHandler = AtomicReference<BookHandler?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book?.name ?? ''),
      ),
      body: Column(
        children: [
          // Your UI elements here
        ],
      ),
    );
  }
}

