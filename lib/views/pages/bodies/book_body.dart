import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

import '../../../managers/preference_manager.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/state_provider.dart';
import '../../../providers/book_provider.dart';
import '../../../blocs/state_bloc.dart';
import '../../../blocs/book_bloc.dart';
import '../../../models/book.dart';
import '../../../utility.dart';
import '../../common_widgets.dart';
import '../bookmarks_page.dart';
import '../chapter_page.dart';
import '../profile_page.dart';

class BookBody extends StatefulWidget {
  @override
  _BookBodyState createState() => _BookBodyState();
}

class _BookBodyState extends State<BookBody> {
 @override
  Widget build(BuildContext context) {
    final PreferenceManager preferences = ApplicationProvider.preferences(context);
    final StateBloc stateBloc = StateProvider.stateBloc(context);
    final BookBloc bookBloc = BookProvider.bookBloc(context);
    return StreamBuilder(
      stream: stateBloc.userKeyStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data != null) {
          final String userKey = snapshot.data;
          return StreamBuilder(
            stream: bookBloc.bookStream,
            builder: (BuildContext context, AsyncSnapshot<MapEntry<String, Book>> snapshot) {
              if (snapshot.data != null) {
                String bookKey = snapshot.data.key;
                Book book = snapshot.data.value;
                String save = preferences.load(bookKey);
                return ListView(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TransitionToImage(
                            width: double.maxFinite,
                            height: MediaQuery.of(context).size.height / 3,
                            fit: BoxFit.cover,
                            placeholder: Container(
                              height: MediaQuery.of(context).size.height / 3,
                              child: LoadingWidget(),
                            ),
                            loadingWidget: Container(
                              height: MediaQuery.of(context).size.height / 3,
                              child: LoadingWidget(),
                            ),
                            image: AdvancedNetworkImage(
                              book.image,
                              useDiskCache: true,
                              timeoutDuration: Duration(seconds: 5),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            book.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 21.0,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 20.0),
                            child: Text(book.summary),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton.icon(
                                onPressed: () async {
                                  bool result = await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => ChapterPage(book.first),
                                  ));
                                  if (result == null) return;
                                  else if (!result) SnackBarUtility.show(context,
                                      "The chapter has been deleted");
                                },
                                color: Colors.black,
                                icon: Icon(Icons.play_arrow, color: Colors.white),
                                label: Text(
                                  "Start Book",
                                  style: TextStyle(color: Colors.white),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              RaisedButton.icon(
                                onPressed: save != null ? () async {
                                  bool result = await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => ChapterPage(save),
                                  ));
                                  if (result == null) return;
                                  else if (!result) SnackBarUtility.show(context,
                                      "The chapter has been deleted");
                                } : null,
                                color: Colors.black,
                                icon: Icon(Icons.redo, color: Colors.white),
                                label: Text(
                                  "Continue Reading",
                                  style: TextStyle(color: Colors.white),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => ProfilePage(userKey),
                                  ));
                                },
                                color: Colors.white,
                                icon: Icon(Icons.person, color: Colors.black),
                                label: Text(
                                  "User Profile",
                                  style: TextStyle(color: Colors.black),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              RaisedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => BookmarksPage(bookKey),
                                  ));
                                },
                                color: Colors.black,
                                icon: Icon(Icons.bookmark, color: Colors.white),
                                label: Text(
                                  "Bookmarks",
                                  style: TextStyle(color: Colors.white),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ],
                );
              } else return LoadingWidget();
            },
          );
        } else return LoadingWidget();
      },
    );
  }
}
