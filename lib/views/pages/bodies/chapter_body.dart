import 'package:cascadw/views/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../../managers/preference_manager.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/chapter_provider.dart';
import '../../../blocs/chapter_bloc.dart';
import '../../../models/chapter.dart';
import '../../../utility.dart';
import '../typer_page.dart';

class ChapterBody extends StatefulWidget {
  final void Function() showLoading;

  ChapterBody(this.showLoading);

  @override
  _ChapterBodyState createState() => _ChapterBodyState();
}

class _ChapterBodyState extends State<ChapterBody> {
  @override
  Widget build(BuildContext context) {
    final PreferenceManager preferences = ApplicationProvider.preferences(context);
    final ChapterBloc chapterBloc = ChapterProvider.chapterBloc(context);
    return StreamBuilder(
      stream: chapterBloc.chapterStream,
      builder: (BuildContext context, AsyncSnapshot<MapEntry<String, Chapter>> snapshot) {
        if (snapshot.data != null) {
          String chapterKey = snapshot.data.key;
          Chapter chapter = snapshot.data.value;
          return StreamBuilder(
            stream: chapterBloc.topStream,
            builder: (BuildContext context, AsyncSnapshot<Map<String, Chapter>> snapshot) {
              if (snapshot.data != null) {
                Map<String, Chapter> top = snapshot.data;
                List<String> sortedTop = List.from(top.keys)
                  ..sort((String a, String b) {
                    if (top[a] == null || top[b] == null) return 0;
                    if (top[a].hearts < top[b].hearts) return -1;
                    else if (top[a].hearts > top[b].hearts) return 1;
                    else return 0;
                  });
                return StreamBuilder(
                  stream: chapterBloc.randomStream,
                  builder: (BuildContext context, AsyncSnapshot<MapEntry<String, Chapter>> snapshot) {
                    String randomKey = snapshot.data?.key;
                    Chapter random = snapshot.data?.value;
                    return ListView(
                      children: <Widget>[
                        SizedBox(height: 15.0),
                        ChapterButton(
                          text: chapter.title,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          onTap: null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 8.0,
                          ),
                          child: Text(chapter.content),
                        ),
                        sortedTop.length > 0
                          ? ChapterButton(
                            text: top[sortedTop[0]].title,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            onTap: () {
                              preferences.save(chapter.book, sortedTop[0]);
                              chapterBloc.chapterKeySink.add(sortedTop[0]);
                              widget.showLoading();
                            },
                          ) : Container(),
                        sortedTop.length > 1
                          ? ChapterButton(
                            text: top[sortedTop[1]].title,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            onTap: () {
                              preferences.save(chapter.book, sortedTop[1]);
                              chapterBloc.chapterKeySink.add(sortedTop[1]);
                              widget.showLoading();
                            },
                          ) : Container(),
                        sortedTop.length > 2
                          ? ChapterButton(
                            text: top[sortedTop[2]].title,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            onTap: () {
                              preferences.save(chapter.book, sortedTop[2]);
                              chapterBloc.chapterKeySink.add(sortedTop[2]);
                              widget.showLoading();
                            },
                          ) : Container(),
                        random != null
                          ? ChapterButton(
                            text: "Random Chapter",
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            onTap: () {
                              preferences.save(chapter.book, randomKey);
                              chapterBloc.chapterKeySink.add(randomKey);
                              widget.showLoading();
                            },
                          ) : Container(),
                        ChapterButton(
                          text: "Write Chapter",
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          onTap: () async {
                            if (await Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => TyperPage(
                                book: chapter.book,
                                source: chapterKey,
                              ),
                            )) ?? false) {
                              chapterBloc.chapterKeySink.add(chapterKey);
                              SnackBarUtility.show(context, "You created a new chapter! We have"
                                  " bookmarked it for you so that you can easily find it.");
                            }
                          },
                        ),
                        (chapter.source?.isNotEmpty ?? false) ? ChapterButton(
                          text: "Previous Chapter",
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          onTap: () {
                            preferences.save(chapter.book, chapter.source);
                            chapterBloc.chapterKeySink.add(chapter.source);
                            widget.showLoading();
                          },
                        ) : Container(),
                        ChapterButton(
                          text: "Book Cover",
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          onTap: () {
                            Navigator.of(context).popUntil(ModalRoute
                                .withName(Navigator.defaultRouteName));
                          },
                        ),
                        SizedBox(height: 8.0),
                      ],
                    );
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

class ChapterButton extends StatelessWidget {
  final void Function() onTap;
  final Color backgroundColor;
  final Color textColor;
  final String text;

  ChapterButton({
    @required this.onTap,
    @required this.backgroundColor,
    @required this.textColor,
    @required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "$text",
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

