import 'dart:async';

import 'package:darter_provider/darter_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../providers/application_provider.dart';
import '../../providers/state_provider.dart';
import '../../providers/chapter_provider.dart';
import '../common_widgets.dart';
import 'bodies/chapter_body.dart';
import 'bars/chapter_bar.dart';

class ChapterPage extends StatefulWidget {
  final String chapterKey;

  ChapterPage(this.chapterKey);

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ChapterProvider(
      stateBloc: StateProvider.stateBloc(context),
      database: ApplicationProvider.database(context),
      chapterKey: widget.chapterKey,
      child: Stack(
        children: <Widget>[
          ChapterScaffold(
            appBar: ChapterBar(),
            body: ChapterBody(showLoading),
          ),
          loading ? Opacity(
            opacity: 0.3,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black,
            ),
          ) : Container(),
          loading ? LoadingWidget() : Container(),
        ],
      ),
    );
  }

  void showLoading() {
    setState(() {
      loading = true;
      Timer(Duration(seconds: 3), () {
        setState(() {
          loading = false;
        });
      });
    });
  }
}

class ChapterScaffold extends BaseScaffold<ChapterInherited> {
  ChapterScaffold({
    Key key,
    PreferredSizeWidget appBar,
    Widget body,
    Widget floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    FloatingActionButtonAnimator floatingActionButtonAnimator,
    List<Widget> persistentFooterButtons,
    Widget drawer,
    Widget endDrawer,
    Widget bottomNavigationBar,
    Widget bottomSheet,
    Color backgroundColor,
    bool resizeToAvoidBottomPadding,
    bool resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    bool extendBody = false,
    Color drawerScrimColor,
    double drawerEdgeDragWidth,
    ShowFunction showFunction,
  }) : super(
    key: key,
    appBar: appBar,
    body: body,
    floatingActionButton: floatingActionButton,
    floatingActionButtonLocation: floatingActionButtonLocation,
    floatingActionButtonAnimator: floatingActionButtonAnimator,
    persistentFooterButtons: persistentFooterButtons,
    drawer: drawer,
    endDrawer: endDrawer,
    bottomNavigationBar: bottomNavigationBar,
    bottomSheet: bottomSheet,
    backgroundColor: backgroundColor,
    resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    primary: primary,
    drawerDragStartBehavior: drawerDragStartBehavior,
    extendBody: extendBody,
    drawerScrimColor: drawerScrimColor,
    drawerEdgeDragWidth: drawerEdgeDragWidth,
    showFunction: showFunction,
  );
}
