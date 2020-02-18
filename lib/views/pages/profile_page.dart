import 'package:darter_provider/darter_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../providers/application_provider.dart';
import '../../providers/profile_provider.dart';
import '../common_widgets.dart';
import 'bodies/profile_body.dart';
import 'bars/clip_bar.dart';

class ProfilePage extends StatefulWidget {
  final String userKey;

  ProfilePage(this.userKey);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ProfileProvider(
      auth: ApplicationProvider.auth(context),
      database: ApplicationProvider.database(context),
      storage: ApplicationProvider.storage(context),
      userKey: widget.userKey,
      child: Stack(
        children: <Widget>[
          ProfileScaffold(
            appBar: ClipBar("User Profile"),
            body: ProfileBody(showLoading),
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

  void showLoading(bool loading) {
    setState(() {
      this.loading = loading;
    });
  }
}

class ProfileScaffold extends BaseScaffold<ProfileInherited> {
  ProfileScaffold({
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