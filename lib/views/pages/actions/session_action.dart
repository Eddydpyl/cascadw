import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_border.dart';

import '../../../providers/session_provider.dart';
import '../../../blocs/session_bloc.dart';

class SessionAction extends StatelessWidget {
  final AnimationController displacementController;
  final AnimationController logoRotationController;
  final AnimationController buttonRotationController;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final Animation<double> fadeAnimation;
  final Animation<double> rotationAnimation;

  SessionAction({
    @required this.displacementController,
    @required this.logoRotationController,
    @required this.buttonRotationController,
    @required this.nameController,
    @required this.emailController,
    @required this.passwordController,
  }): fadeAnimation = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(displacementController),
      rotationAnimation = Tween(
        begin: 0.0,
        end: 120.0,
      ).animate(buttonRotationController);

  @override
  Widget build(BuildContext context) {
    final SessionBloc sessionBloc = SessionProvider.sessionBloc(context);
    return StreamBuilder(
      stream: sessionBloc.modeStream,
      initialData: SessionMode.SIGN_IN,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.data != null) {
          final int mode = snapshot.data;
          return FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              height: 75.0,
              width: 75.0,
              child: FloatingActionButton(
                backgroundColor: Colors.black,
                shape: PolygonBorder(
                  sides: 6,
                  borderRadius: 15.0,
                  rotate: rotationAnimation.value,
                  border: BorderSide.none,
                ),
                onPressed: () {
                  switch (mode) {
                    case SessionMode.SIGN_IN: {
                      sessionBloc.emailSink.add(emailController.text);
                      sessionBloc.passwordSink.add(passwordController.text);
                      break;
                    }
                    case SessionMode.SIGN_UP: {
                      sessionBloc.nameSink.add(nameController.text);
                      sessionBloc.emailSink.add(emailController.text);
                      sessionBloc.passwordSink.add(passwordController.text);
                      break;
                    }
                    case SessionMode.RESET: {
                      sessionBloc.modeSink.add(SessionMode.SIGN_IN);
                      logoRotationController.reverse();
                      buttonRotationController.reverse();
                      nameController.clear();
                      emailController.clear();
                      passwordController.clear();
                      break;
                    }
                  }
                },
                child: Icon(
                  mode == SessionMode.RESET
                      ? Icons.arrow_back
                      : Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else return Container();
      },
    );
  }
}