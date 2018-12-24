import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospital Token System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Tokens'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isUpdating = false;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _incrementToken() {
    setState(() {
      _isUpdating = true;
      final DocumentReference postRef =
          Firestore.instance.document('token/tokenNumber');
      Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot postSnapshot = await tx.get(postRef);
        if (postSnapshot.exists) {
          print('running transaction');
          await tx.update(postRef,
              <String, dynamic>{'token': postSnapshot.data['token'] + 1});
          setState(() {
            // Future.delayed(const Duration(microseconds: 500));
            _isUpdating = false;
          });
        }
      });
    });
  }

  void _decrementToken() {}

  @override
  Widget build(BuildContext context) {
    print(_isUpdating);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Token Number is:',
              style: Theme.of(context).textTheme.overline,
            ),
            Container(
              height: 150.0,
              child:
                  _isUpdating ? CircularProgressIndicator() : _tockenNumber(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.arrow_drop_down),
                    tooltip: 'Decrement the token',
                    iconSize: 50.0,
                    onPressed: _decrementToken),
                SizedBox(
                  width: 30.0,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_drop_up),
                  tooltip: 'Increment the token',
                  color: Colors.red,
                  iconSize: 50.0,
                  onPressed: _incrementToken,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _tockenNumber() {
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('token')
            .document('tokenNumber')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return Text(
                snapshot.data['token'].toString(),
                style: Theme.of(context).textTheme.display4,
              );
          }
        });
  }
}
