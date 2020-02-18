import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

import '../../../blocs/bookmarks_bloc.dart';
import '../../../providers/bookmarks_provider.dart';
import '../../../utility.dart';
import '../../../models/bookmark.dart';
import '../../../models/chapter.dart';
import '../../../models/user.dart';
import '../../common_widgets.dart';
import '../chapter_page.dart';

class BookmarksBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BookmarksBloc bookmarksBloc = BookmarksProvider.bookmarksBloc(context);
    return StreamBuilder(
      stream: bookmarksBloc.bookmarksStream,
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, Bookmark>> snapshot) {
        if (snapshot.data != null) {
          final Map<String, Bookmark> bookmarks = snapshot.data;
          return StreamBuilder(
            stream: bookmarksBloc.chaptersStream,
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, Chapter>> snapshot) {
              if (snapshot.data != null) {
                final Map<String, Chapter> chapters = snapshot.data;
                return StreamBuilder(
                  stream: bookmarksBloc.usersStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, AppUser>> snapshot) {
                    if (snapshot.data != null) {
                      final Map<String, AppUser> users = snapshot.data;
                      final List<Widget> widgets = [SizedBox(height: 8.0)];
                      for (Bookmark bookmark in bookmarks.values) {
                        if (chapters[bookmark.chapter] != null) {
                          widgets.add(BookmarkWidget(
                            bookmarksBloc: bookmarksBloc,
                            chapterKey: bookmark.chapter,
                            chapter: chapters[bookmark.chapter],
                            user: users[chapters[bookmark.chapter].uid],
                          ));
                        }
                      }
                      widgets.add(SizedBox(height: 8.0));
                      return ListView(children: widgets);
                    } else return LoadingWidget();
                  },
                );
              } else return LoadingWidget();
            },
          );
        } else return LoadingWidget();
      },
    );
  }
}

class BookmarkWidget extends StatefulWidget {
  final BookmarksBloc bookmarksBloc;
  final String chapterKey;
  final Chapter chapter;
  final AppUser user;

  BookmarkWidget({
    @required this.bookmarksBloc,
    @required this.chapterKey,
    @required this.chapter,
    @required this.user,
  });

  @override
  _BookmarkWidgetState createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget> {
  bool bookmarked;
  bool hearted;
  bool deleted;
  int hearts;

  @override
  void initState() {
    super.initState();
    bookmarked = true;
    deleted = false;
    hearted = widget.chapter.hearted;
    hearts = widget.chapter.hearts;
  }

  @override
  Widget build(BuildContext context) {
    return !deleted ? Container(
      height: 90.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: Colors.black,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(40.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () async {
                bool result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ChapterPage(widget.chapterKey),
                ));
                if (result == null) return;
                else if (!result) {
                  setState(() {
                    deleted = true;
                    SnackBarUtility.show(context,
                        "The chapter has been deleted");
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 16.0),
                    child: (widget.user.avatar?.isNotEmpty ?? false)
                      ? CircleAvatar(
                        radius: 22.0,
                        backgroundColor: Colors.black,
                        child: TransitionToImage(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(22.0),
                          placeholder: InitialsText(widget.user.name, Colors.white),
                          loadingWidget: InitialsText(widget.user.name, Colors.white),
                          image: AdvancedNetworkImage(
                            widget.user.avatar,
                            useDiskCache: true,
                            timeoutDuration: Duration(seconds: 5),
                          ),
                        ),
                      ) : CircleAvatar(
                        radius: 22.0,
                        backgroundColor: Colors.black,
                        child: InitialsText(widget.user.name, Colors.white),
                      ),
                  ),
                  Flexible(
                    child: Text(widget.chapter.title),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (!bookmarked) return;
                      bookmarked = !bookmarked;
                      widget.bookmarksBloc.bookmarkSink.add(widget.chapterKey);
                      SnackBarUtility.show(context, "Your bookmark has been deleted.");
                    });
                  },
                  icon: Icon(
                    bookmarked ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: Colors.black,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          hearted = !hearted;
                          hearts = hearts + (hearted ? 1 : -1);
                          widget.bookmarksBloc.heartSink.add(widget.chapterKey);
                        });
                      },
                      icon: Icon(
                        hearted ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      hearts.toString(),
                      style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                          height: 0.1
                      ),
                    ),
                    SizedBox(height: 10.0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ) : Container(height: 0.0);
  }
}

