import 'dart:async';
import 'dart:math';

import 'package:darter_bloc/darter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../models/chapter.dart';
import '../../../blocs/state_bloc.dart';
import '../../../blocs/typer_bloc.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/state_provider.dart';
import '../../../providers/typer_provider.dart';
import '../../../utility.dart';
import '../../common_widgets.dart';

class TyperBody extends StatefulWidget {
  final String book;
  final String source;
  final String chapterKey;
  final Chapter chapter;

  TyperBody({
    this.book,
    this.source,
    this.chapterKey,
    this.chapter,
  });

  @override
  _TyperBodyState createState() => _TyperBodyState();
}

class _TyperBodyState extends State<TyperBody> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  StreamSubscription exceptions;

  @override
  void initState() {
    super.initState();
    if (widget.chapter != null) {
      titleController.text = widget.chapter.title;
      contentController.text = widget.chapter.content;
    }
  }

  @override
  void didChangeDependencies() {
    exceptions?.cancel();
    final TyperBloc typerBloc = TyperProvider.typerBloc(context);
    exceptions = typerBloc.exceptionStream.listen((e) {
      if (e is SuccessfulException && e.result != null)
        Navigator.of(context).pop(e.result);
    }); super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final StateBloc stateBloc = StateProvider.stateBloc(context);
    final TyperBloc typerBloc = TyperProvider.typerBloc(context);
    return StreamBuilder(
      stream: stateBloc.userKeyStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data != null) {
          final String userKey = snapshot.data;
          return ListView(
            children: <Widget>[
              SizedBox(height: 16.0),
              TyperInput(
                controller: titleController,
                textInputAction: TextInputAction.done,
                hintText: "Describe the reader's choice ...",
                textAlign: TextAlign.center,
              ),
              Container(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 300.0,
                    maxHeight: 300.0,
                  ),
                  child: TyperInput(
                    controller: contentController,
                    textInputAction: TextInputAction.newline,
                    hintText: "Narrate the consequences ...",
                    textAlign: TextAlign.start,
                    expands: true,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TyperButton(
                      text: "Cancel",
                      onTap: () {
                        Navigator.of(context).pop(null);
                      },
                    ),
                  ),
                  Expanded(
                    child: TyperButton(
                      text: "Save",
                      onTap: () {
                        if (titleController.text?.isNotEmpty ?? false) {
                          if (contentController.text?.isNotEmpty ?? false) {
                            if (widget.chapterKey == null) {
                              Chapter chapter = Chapter(book: widget.book,
                                random: Random().nextInt(Chapter.MAX_RANDOM),
                                source: widget.source, uid: userKey,
                                title: titleController.text, hearts: 0,
                                content: contentController.text,
                              ); typerBloc.createSink.add(chapter);
                            } else {
                              Chapter chapter = Chapter(title: titleController.text, content: contentController.text);
                              typerBloc.updateSink.add(MapEntry(widget.chapterKey, chapter));
                            }
                          } else SnackBarUtility.show(context,
                              "Can't create a chapter without a body.");
                        } else SnackBarUtility.show(context,
                            "Can't create a chapter without a title.");
                      },
                    ),
                  ),
                ],
              ),
              widget.chapterKey != null ? DeleteButton(typerBloc,
                  widget.chapter.book, widget.chapterKey)
                  : Container(height: 0.0),
            ],
          );
        } else return LoadingWidget();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
    exceptions?.cancel();
  }
}

class TyperInput extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextAlign textAlign;
  final String hintText;
  final bool expands;

  TyperInput({
    @required this.controller,
    @required this.textInputAction,
    @required this.textAlign,
    this.hintText,
    this.expands
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        textInputAction: textInputAction,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Colors.black,
        textAlign: textAlign,
        expands: expands ?? false,
        maxLines: null,
        decoration: InputDecoration(
          hintText: hintText,
          focusColor: Colors.black,
          hoverColor: Colors.black,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }
}

class TyperButton extends StatelessWidget {
  final void Function() onTap;
  final String text;

  TyperButton({@required this.onTap, @required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
          color: Colors.black,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final TyperBloc typerBloc;
  final String bookKey;
  final String chapterKey;

  DeleteButton(this.typerBloc, this.bookKey, this.chapterKey);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: RaisedButton(
        onPressed: () async {
          showDialog(context: context, builder: (context) {
            return AlertDialog(
              title: Text("Are you sure you want to delete this chapter?"),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    "Yes",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  onPressed: () {
                    typerBloc.deleteSink.add(chapterKey);
                    ApplicationProvider.preferences(context).remove(bookKey);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                    "No",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          });
        },
        color: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60.0),
        ),
        child: Text(
          "Delete Chapter",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}





