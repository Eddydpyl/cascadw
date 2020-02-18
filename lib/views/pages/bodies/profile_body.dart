import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:image_picker/image_picker.dart';

import '../../../providers/state_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../blocs/state_bloc.dart';
import '../../../blocs/profile_bloc.dart';
import '../../../blocs/uploader_bloc.dart';
import '../../../models/user.dart';
import '../../../utility.dart';
import '../../common_widgets.dart';

class ProfileBody extends StatefulWidget {
  final void Function(bool) showLoading;

  ProfileBody(this.showLoading);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {

  StreamSubscription subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscription == null) {
      subscription = ProfileProvider.uploaderBloc(context).pathStream
          .listen((String path) => widget.showLoading(path == UploaderBloc.uploading));
    }
  }

  @override
  Widget build(BuildContext context) {
    final StateBloc stateBloc = StateProvider.stateBloc(context);
    final ProfileBloc profileBloc = ProfileProvider.profileBloc(context);
    final UploaderBloc uploaderBloc = ProfileProvider.uploaderBloc(context);
    return StreamBuilder(
      stream: stateBloc.userKeyStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data != null) {
          final String uid = snapshot.data;
          return StreamBuilder(
            stream: profileBloc.userStream,
            builder: (BuildContext context,
                AsyncSnapshot<MapEntry<String, AppUser>> snapshot) {
              if (snapshot.data != null) {
                final String userKey = snapshot.data.key;
                final AppUser user = snapshot.data.value;
                return StreamBuilder(
                  stream: uploaderBloc.pathStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<String> snapshot) {
                    final String path = snapshot.data;
                    return Stack(
                      children: <Widget>[
                        ListView(
                          children: <Widget>[
                            ProfileAvatar(
                              profileBloc: profileBloc,
                              editable: uid == userKey,
                              user: user,
                              path: path,
                            ),
                            uid == userKey ? ProfileEdit(
                              profileBloc: profileBloc,
                              user: user,
                              path: path,
                            ) : ProfileAbout(user: user),
                          ],
                        ),
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

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }
}

class ProfileAvatar extends StatelessWidget {
  final ProfileBloc profileBloc;
  final bool editable;
  final AppUser user;
  final String path;

  ProfileAvatar({
    @required this.profileBloc,
    @required this.editable,
    @required this.user,
    @required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 16.0),
        GestureDetector(
          onTap: () async {
            if (editable) {
              File file = await ImagePicker
                  .pickImage(source: ImageSource.gallery,
                  maxHeight: 1500, maxWidth: 1500);
              if (file != null) {
                ProfileProvider.uploaderBloc(context)
                    .fileSink.add(file.readAsBytesSync());
              }
            }
          },
          child: _avatarWidget(user),
        ),
        SizedBox(height: 8.0),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 21.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }

  Widget _avatarWidget(AppUser user) {
    if ((path?.isNotEmpty ?? false)
        || (user.avatar?.isNotEmpty ?? false)) {
      return CircleAvatar(
        radius: 40.0,
        backgroundColor: Colors.black,
        child: TransitionToImage(
          width: double.maxFinite,
          height: double.maxFinite,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(40.0),
          placeholder: InitialsText(user.name, Colors.white),
          loadingWidget: InitialsText(user.name, Colors.white),
          image: AdvancedNetworkImage(
            path ?? user.avatar,
            useDiskCache: true,
            timeoutDuration: Duration(seconds: 5),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 40.0,
        backgroundColor: Colors.black,
        child: InitialsText(user.name, Colors.white),
      );
    }
  }
}

class ProfileEdit extends StatefulWidget {
  final ProfileBloc profileBloc;
  final AppUser user;
  final String path;

  ProfileEdit({
    @required this.profileBloc,
    @required this.user,
    @required this.path,
  });

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    emailController.text = widget.user.email;
    aboutController.text = widget.user.about;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Text(
            "About Me:",
            style: TextStyle(fontSize: 12.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Container(
            height: 150.0,
            child: TextField(
              maxLines: null,
              minLines: null,
              expands: true,
              maxLength: 250,
              controller: aboutController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              hintText: "Username",
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.mail),
              hintText: "Email",
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
        Container(
          height: 50.0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: RaisedButton(
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              if (widget.path != UploaderBloc.uploading) {
                AppUser update = AppUser(
                    name: nameController.text,
                    email: emailController.text,
                    about: aboutController.text,
                    avatar: widget.path ?? "");
                widget.profileBloc.updateSink.add(update);
              }
            },
            child: Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    aboutController.dispose();
  }
}

class ProfileAbout extends StatelessWidget {
  final AppUser user;

  ProfileAbout({
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Text(
            "About Me:",
            style: TextStyle(fontSize: 12.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Container(
            height: 150.0,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Colors.grey
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                user.about,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePassword extends StatefulWidget {
  final ProfileBloc profileBloc;

  ProfilePassword({
    @required this.profileBloc,
  });

  @override
  _ProfilePasswordState createState() => _ProfilePasswordState();
}

class _ProfilePasswordState extends State<ProfilePassword> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            obscureText: true,
            controller: oldPasswordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              hintText: "Old Password",
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            obscureText: true,
            controller: passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              hintText: "New Password",
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            obscureText: true,
            controller: rePasswordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              hintText: "Confirm Password",
              contentPadding: EdgeInsets.all(0),
            ),
          ),
        ),
        Container(
          height: 50.0,
          margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: RaisedButton(
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              if (passwordController.text?.isEmpty ?? true)
                SnackBarUtility.show(context, "The new password can't be empty.");
              else if (passwordController.text != rePasswordController.text)
                SnackBarUtility.show(context, "The passwords don't match.");
              else widget.profileBloc.passwordSink.add(MapEntry(oldPasswordController.text, passwordController.text));
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    oldPasswordController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
  }
}

class ProfileChapters extends StatelessWidget {
  final String userKey;

  ProfileChapters({
    @required this.userKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: RaisedButton(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () {
          // TODO: Navigate to user chapter's.
        },
        child: Text(
          "User Chapters",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}



