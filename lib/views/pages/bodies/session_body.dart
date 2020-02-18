import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import '../../../providers/session_provider.dart';
import '../../../blocs/session_bloc.dart';
import '../../clippers/session_clipper.dart';

class SessionBody extends StatelessWidget {
  final AnimationController displacementController;
  final AnimationController logoRotationController;
  final AnimationController buttonRotationController;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final double width;
  final double height;

  final Animation<Offset> logoTranslateAnimation;
  final Animation<double> formTranslateAnimation;
  final Animation<double> logoRotationAnimation;

  SessionBody({
    @required this.displacementController,
    @required this.logoRotationController,
    @required this.buttonRotationController,
    @required this.nameController,
    @required this.emailController,
    @required this.passwordController,
    @required this.width,
    @required this.height,
  }) : logoTranslateAnimation = Tween<Offset>(
        begin: Offset((width / 2) - 125, (height / 2) - 125),
        end: Offset(-75.0, -75.0),
       ).animate(displacementController),
      formTranslateAnimation = Tween(
        begin: -550.0,
        end: 0.0,
      ).animate(displacementController),
      logoRotationAnimation = Tween(
        begin: 0.0,
        end: 120.0,
      ).animate(logoRotationController);

  @override
  Widget build(BuildContext context) {
    final SessionBloc sessionBloc = SessionProvider.sessionBloc(context);
    return StreamBuilder(
      stream: sessionBloc.modeStream,
      initialData: SessionMode.SIGN_IN,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.data != null) {
          final int mode = snapshot.data;
          return Stack(
            children: <Widget>[
              logoWidget(context),
              formWidget(context, mode),
            ],
          );
        } else return Container();
      },
    );
  }

  Widget logoWidget(BuildContext context) {
    return Positioned(
      top: logoTranslateAnimation.value.dy,
      right: logoTranslateAnimation.value.dx,
      child: Container(
        width: 250.0,
        height: 250.0,
        child: ClipPolygon(
          borderRadius: 15.0,
          rotate: logoRotationAnimation.value,
          sides: 6,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/initials.png",
              width: 150.0,
              height: 150.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget formWidget(BuildContext context, int mode) {
    return Positioned(
      bottom: formTranslateAnimation.value,
      left: formTranslateAnimation.value,
      right: 0.0,
      child: ClipPath(
        clipper: SessionClipper(),
        child: Container(
          height: height > width
              ? height - 100 : height,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: width > height
                      ? width * 0.07 : 0.0,
                  top: 52.0,
                  bottom: 32.0,
                ),
                child: Text(
                  "CREATE\nSTORIES\nTOGETHER",
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: mode == SessionMode.SIGN_IN ? signInWidget(context, width, height)
                        : mode == SessionMode.SIGN_UP ? signUpWidget(context, width, height)
                        : recoveryWidget(context, width, height),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget signInWidget(BuildContext context, double width, double height) {
    return Padding(
      key: Key("SignIn"),
      padding: EdgeInsets.only(right: width > height ? 100.0 : 0.0),
      child: Column(
        children: <Widget>[
          Text(
            "Sign in",
            style: TextStyle(
              fontSize: 21.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: emailController,
            onSubmitted: (String email) => SessionProvider
                .sessionBloc(context).emailSink.add(email),
            decoration: InputDecoration(
              hintText: "Email",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffcfcfcf),
                  style: BorderStyle.solid,
                ),
              ),
              prefixIcon: Icon(
                Icons.email,
                color: Color(0xffcfcfcf),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: passwordController,
            onSubmitted: (String password) => SessionProvider
                .sessionBloc(context).passwordSink.add(password),
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffcfcfcf),
                  style: BorderStyle.solid,
                ),
              ),
              prefixIcon: Icon(
                Icons.lock,
                color: Color(0xffcfcfcf),
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  SessionProvider.sessionBloc(context)
                      .modeSink.add(SessionMode.RESET);
                  logoRotationController.reset();
                  buttonRotationController.reset();
                  logoRotationController.forward();
                  buttonRotationController.forward();
                  nameController.clear();
                  emailController.clear();
                  passwordController.clear();
                },
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                    fontSize: 14.0,
                    decorationStyle: TextDecorationStyle.solid,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Don't yet have account? ",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  SessionProvider.sessionBloc(context)
                      .modeSink.add(SessionMode.SIGN_UP);
                  logoRotationController.reset();
                  buttonRotationController.reset();
                  logoRotationController.forward();
                  buttonRotationController.forward();
                  nameController.clear();
                  emailController.clear();
                  passwordController.clear();
                },
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 16.0,
                    decorationStyle: TextDecorationStyle.solid,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget signUpWidget(BuildContext context, double width, double height) {
    return Padding(
      key: Key("SignUp"),
      padding: EdgeInsets.only(right: width > height ? 100.0 : 0.0),
      child: Column(
        children: <Widget>[
          Text(
            "Sign up",
            style: TextStyle(
              fontSize: 21.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: nameController,
            onSubmitted: (String name) => SessionProvider
                .sessionBloc(context).nameSink.add(name),
            decoration: InputDecoration(
              hintText: "Username",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffcfcfcf),
                  style: BorderStyle.solid,
                ),
              ),
              prefixIcon: Icon(
                Icons.account_circle,
                color: Color(0xffcfcfcf),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: emailController,
            onSubmitted: (String email) => SessionProvider
                .sessionBloc(context).emailSink.add(email),
            decoration: InputDecoration(
              hintText: "E-mail",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffcfcfcf),
                  style: BorderStyle.solid,
                ),
              ),
              prefixIcon: Icon(
                Icons.email,
                color: Color(0xffcfcfcf),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: passwordController,
            onSubmitted: (String password) => SessionProvider
                .sessionBloc(context).passwordSink.add(password),
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffcfcfcf),
                  style: BorderStyle.solid,
                ),
              ),
              prefixIcon: Icon(
                Icons.lock,
                color: Color(0xffcfcfcf),
              ),
            ),
          ),
          SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Already have account? ",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  SessionProvider.sessionBloc(context)
                      .modeSink.add(SessionMode.SIGN_IN);
                  logoRotationController.reverse();
                  buttonRotationController.reverse();
                  nameController.clear();
                  emailController.clear();
                  passwordController.clear();
                },
                child: Text(
                  "Sign in",
                  style: TextStyle(
                    fontSize: 16.0,
                    decorationStyle: TextDecorationStyle.solid,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget recoveryWidget(BuildContext context, double width, double height) {
    return Padding(
      key: Key("Recovery"),
      padding: EdgeInsets.only(right: width > height ? 100.0 : 0.0),
      child: Column(
        children: <Widget>[
          Text(
            "Password recovery",
            style: TextStyle(
              fontSize: 21.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
          SizedBox(height: 20.0),
          TextField(
            controller: emailController,
            onSubmitted: (String email) => SessionProvider
                .sessionBloc(context).emailSink.add(email),
            decoration: InputDecoration(
              hintText: "Email",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffcfcfcf),
                  style: BorderStyle.solid,
                ),
              ),
              prefixIcon: Icon(
                Icons.email,
                color: Color(0xffcfcfcf),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          RaisedButton(
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                "Send email",
                style: TextStyle(color: Colors.white),
              ),
            ),
            onPressed: () => SessionProvider.sessionBloc(context)
                .emailSink.add(emailController.text),
          )
        ],
      ),
    );
  }
}

