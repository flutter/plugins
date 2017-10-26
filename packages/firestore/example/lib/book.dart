import 'dart:async';

import 'package:firestore/firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BookWidget extends StatefulWidget {
  final String bookModel;
  final Animation<double> animation;

  BookWidget({Key key, @required this.animation, @required this.bookModel});

  @override
  _BookState createState() => new _BookState();
}

class _BookState extends State<BookWidget> {
  List<String> _users = new List<String>();
  StreamSubscription<QuerySnapshot> _userSub;

  @override
  void initState() {
    super.initState();
    _userSub = Firestore.instance
        .collection('books/${widget.bookModel}/users')
        .snapshots
        .listen((snap) {
      setState(() {
        snap.documentChanges.forEach((docChange) {
          switch (docChange.type) {
            case DocumentChangeType.added:
              _users.insert(docChange.newIndex, docChange.document.data["id"]);
              break;
            case DocumentChangeType.removed:
              _users.removeAt(docChange.oldIndex);
              break;
            default:
              _users[docChange.newIndex] = docChange.document.data["id"];
          }
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userSub.cancel();
  }

  Future<Null> _addUserToBook() async {
    DocumentReference ref = Firestore.instance
        .collection('books/${widget.bookModel}/users')
        .document();
    await ref.setData(<String, String>{"id": ref.path.split("/").last});
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new SizeTransition(
        child: new Column(
          children: <Widget>[
            new Text(
              "Book: ${widget.bookModel}",
              style: Theme.of(context).textTheme.title,
            ),
            new Text("Users: ${_users.isEmpty ? "None" : _users.join(",")}"),
            new MaterialButton(
              onPressed: () => _addUserToBook(),
              child: new Icon(Icons.add),
            ),
          ],
        ),
        sizeFactor: widget.animation,
      ),
    );
  }
}
