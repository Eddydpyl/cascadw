import 'package:darter_provider/darter_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../providers/application_provider.dart';
import '../../providers/session_provider.dart';
import 'actions/session_action.dart';
import 'bodies/session_body.dart';

class SessionPage extends StatefulWidget {
  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AnimationController displacementController;
  AnimationController logoRotationController;
  AnimationController buttonRotationController;

  @override
  void initState() {
    super.initState();
    displacementController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });

    logoRotationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });

    buttonRotationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
      setState(() {});
    });

    Future.delayed(Duration(seconds: 1)).then((_) {
      displacementController.forward();
      logoRotationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return SessionProvider(
      auth: ApplicationProvider.auth(context),
      database: ApplicationProvider.database(context),
      child: SafeArea(
        child: SessionScaffold(
          backgroundColor: Colors.black,
          body: SessionBody(
            displacementController: displacementController,
            logoRotationController: logoRotationController,
            buttonRotationController: buttonRotationController,
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
            width: width,
            height: height,
          ),
          floatingActionButton: SessionAction(
            displacementController: displacementController,
            logoRotationController: logoRotationController,
            buttonRotationController: buttonRotationController,
            nameController: nameController,
            emailController: emailController,
            passwordController: passwordController,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    displacementController.dispose();
    logoRotationController.dispose();
    buttonRotationController.dispose();
  }
}

class SessionScaffold extends BaseScaffold<SessionInherited> {
  SessionScaffold({
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


