import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Voting Apps',
      home: new MyHomePage(title: 'Vote',),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Center(child: new Text(title))),
      body: new StreamBuilder(
        stream: Firestore.instance.collection('voting').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          return new ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 10.0),
              itemExtent: 55.0,
              itemBuilder: (context, index) {
                return _buildListItem(context, snapshot.data.documents[index]);
              });
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      key: new ValueKey(document.documentID),
      title: new Container(
        decoration: new BoxDecoration(
            border: new Border.all(color: new Color(0x80000000)),
            borderRadius: new BorderRadius.circular(5.0)),
        padding: const EdgeInsets.all(10.0),
        child: new Row(
          children: <Widget>[
            new Expanded(child: new Text(document['name'])),
            new Text(document['votes'].toString())
          ],
        ),
      ),
      onTap: () => Firestore.instance.runTransaction((transaction) async {
            DocumentSnapshot freshSnap =
                await transaction.get(document.reference);
            await transaction
                .update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
          }),
    );
  }
}
