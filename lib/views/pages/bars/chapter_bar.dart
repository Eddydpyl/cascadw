import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

import '../../../providers/state_provider.dart';
import '../../../providers/chapter_provider.dart';
import '../../../blocs/state_bloc.dart';
import '../../../blocs/chapter_bloc.dart';
import '../../../models/chapter.dart';
import '../../../models/user.dart';
import '../../../utility.dart';
import '../../common_widgets.dart';
import '../profile_page.dart';
import '../typer_page.dart';

class ChapterBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final StateBloc stateBloc = StateProvider.stateBloc(context);
    final ChapterBloc chapterBloc = ChapterProvider.chapterBloc(context);
    return StreamBuilder(
      stream: stateBloc.userKeyStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data != null) {
          final String uid = snapshot.data;
          return StreamBuilder(
            stream: chapterBloc.chapterStream,
            builder: (BuildContext context,
                AsyncSnapshot<MapEntry<String, Chapter>> snapshot) {
              if (snapshot.data != null) {
                final String chapterKey = snapshot.data.key;
                Chapter chapter = snapshot.data.value;
                return StreamBuilder(
                  stream: chapterBloc.userStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<MapEntry<String, AppUser>> snapshot) {
                    if (snapshot.data != null) {
                      String userKey = snapshot.data.key;
                      AppUser user = snapshot.data.value;
                      return ChapterRect(
                        chapterBloc: chapterBloc,
                        chapterKey: chapterKey,
                        chapter: chapter,
                        user: user,
                        uid: uid,
                      );
                    } else return LoadingRect();
                  },
                );
              } else return LoadingRect();
            },
          );
        } else return LoadingRect();
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 2);
}

class ChapterRect extends StatelessWidget {
  final ChapterBloc chapterBloc;
  final String chapterKey;
  final Chapter chapter;
  final AppUser user;
  final String uid;

  ChapterRect({
    @required this.chapterBloc,
    @required this.chapterKey,
    @required this.chapter,
    @required this.user,
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(40.0),
      ),
      child: Container(
        height: kToolbarHeight * 2,
        color: Colors.black,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Container(
                margin: EdgeInsets.only(bottom: 15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ProfilePage(chapter.uid),
                    ));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 32, right: 8.0),
                        child: (user.avatar?.isNotEmpty ?? false)
                            ? CircleAvatar(
                              radius: 22.0,
                              backgroundColor: Colors.white,
                              child: TransitionToImage(
                                width: double.maxFinite,
                                height: double.maxFinite,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(22.0),
                                placeholder: InitialsText(user.name, Colors.black),
                                loadingWidget: InitialsText(user.name, Colors.black),
                                image: AdvancedNetworkImage(
                                  user.avatar,
                                  useDiskCache: true,
                                  timeoutDuration: Duration(seconds: 5),
                                ),
                              ),
                            )
                            : CircleAvatar(
                                radius: 22.0,
                                backgroundColor: Colors.white,
                                child: InitialsText(user.name, Colors.black),
                              ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Author:",
                              style: TextStyle(color: Colors.white, fontSize: 11.0),
                            ),
                            Text(
                              user.name,
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ChapterInteractions(
              chapterBloc: chapterBloc,
              userKey: uid,
              chapterKey: chapterKey,
              chapter: chapter,
            ),
          ],
        ),
      ),
    );
  }
}

class ChapterInteractions extends StatefulWidget {
  final ChapterBloc chapterBloc;
  final String userKey;
  final String chapterKey;
  final Chapter chapter;

  ChapterInteractions({
    @required this.chapterBloc,
    @required this.userKey,
    @required this.chapterKey,
    @required this.chapter,
  });

  @override
  _ChapterInteractionsState createState() => _ChapterInteractionsState();
}

class _ChapterInteractionsState extends State<ChapterInteractions> {
  int hearts;
  bool bookmarked;
  bool hearted;

  @override
  void initState() {
    super.initState();
    hearts = widget.chapter.hearts;
    bookmarked = widget.chapter.bookmarked;
    hearted = widget.chapter.hearted;
  }

  @override
  void didUpdateWidget(ChapterInteractions old) {
    super.didUpdateWidget(old);
    setState(() {
      hearts = widget.chapter.hearts;
      bookmarked = widget.chapter.bookmarked;
      hearted = widget.chapter.hearted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.userKey == widget.chapter.uid ? IconButton(
            onPressed: () async {
              bool result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => TyperPage(
                  chapterKey: widget.chapterKey,
                  chapter: widget.chapter,
                ),
              ));
              if (result == null) return;
              else if (result) {
                widget.chapterBloc.chapterKeySink.add(widget.chapterKey);
                SnackBarUtility.show(context, "You updated your chapter!");
              } else Navigator.of(context).pop(result);
            },
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ) : Container(height: 0.0),
          IconButton(
            onPressed: () {
              setState(() {
                widget.chapterBloc.bookmarkSink.add(!bookmarked);
                bookmarked = !bookmarked;
                if (bookmarked) SnackBarUtility.show(context,
                    "You have bookmarked this chapter.");
                else SnackBarUtility.show(context,
                    "Your bookmark has been deleted.");
              });
            },
            icon: Icon(
              bookmarked ? Icons.bookmark
                  : Icons.bookmark_border,
              color: Colors.white,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    hearts = hearted ? (hearts - 1) : (hearts + 1);
                    widget.chapterBloc.heartSink.add(!hearted);
                    hearted = !hearted;
                  });
                },
                icon: Icon(
                  hearted ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
              Text(
                "$hearts",
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    height: 0.1
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ],
      ),
    );
  }
}

class LoadingRect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(40.0),
      ),
      child: Container(
        height: kToolbarHeight * 2,
        color: Colors.black,
        child: Container(),
      ),
    );
  }
}


