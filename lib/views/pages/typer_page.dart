import 'package:darter_provider/darter_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../providers/application_provider.dart';
import '../../providers/typer_provider.dart';
import '../../models/chapter.dart';
import 'bodies/typer_body.dart';
import 'bars/clip_bar.dart';

class TyperPage extends StatelessWidget {
  final String book;
  final String source;
  final String chapterKey;
  final Chapter chapter;

  TyperPage({this.book, this.source, this.chapterKey, this.chapter}) {
    if (book == null && chapterKey == null)
      throw Exception("Either a book or a chapterKey must be provided.");
    if (source == null && chapterKey == null)
      throw Exception("Either a source or a chapterKey must be provided.");
    if (chapterKey == null && chapter != null)
      throw Exception("Both the chapterKey and chapter must be provided.");
    if (chapterKey != null && chapter == null)
      throw Exception("Both the chapterKey and chapter must be provided.");
  }

  @override
  Widget build(BuildContext context) {
    return TyperProvider(
      database: ApplicationProvider.database(context),
      child: TyperScaffold(
        appBar: ClipBar(chapterKey != null
            ? "Edit Chapter" : "Write Chapter"),
        body: TyperBody(
          book: book,
          source: source,
          chapterKey: chapterKey,
          chapter: chapter,
        ),
      ),
    );
  }
}

class TyperScaffold extends BaseScaffold<TyperInherited> {
  TyperScaffold({
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