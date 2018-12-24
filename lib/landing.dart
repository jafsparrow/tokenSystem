import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Landing extends StatefulWidget {
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  bool _isUpdating = false;
  int _currentValue = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      // color: Colors.teal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[_tokenContainer(), _intervalIndicators()],
      ),
    );
  }

  Widget _tokenContainer() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            // color: Colors.red,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Text('10', style: Theme.of(context).textTheme.display4),
                _firestoreToken(),
                Text(
                  'Current Token Number',
                  style: Theme.of(context).textTheme.subtitle,
                )
              ],
            )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 40.0,
                icon: Icon(
                  Icons.navigate_before,
                  color: Colors.orange,
                ),
                disabledColor: Colors.grey,
                onPressed: _isUpdating
                    ? null
                    : () {
                        _updateToken(-1);
                      },
              ),
              SizedBox(
                width: 40.0,
              ),
              IconButton(
                icon: Icon(Icons.restore),
                onPressed: () {},
              ),
              SizedBox(
                width: 40.0,
              ),
              IconButton(
                iconSize: 40.0,
                icon: Icon(
                  Icons.navigate_next,
                  color: Colors.orange,
                ),
                disabledColor: Colors.red,
                onPressed: _isUpdating
                    ? null
                    : () {
                        _updateToken(1);
                      },
              ),
            ],
          )
        ],
      ),
    );
  }

  void _updateToken(int value) async {
    setState(() {
      print('inside trasaction');
      _isUpdating = true;
    });
    final DocumentReference postRef =
        Firestore.instance.collection('token').document('tokenNumber');
    Firestore.instance.runTransaction((Transaction tx) async {
      print('inside transaction block');
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        try {
          await tx.update(postRef,
              <String, dynamic>{'token': postSnapshot.data['token'] + value});
          setState(() {
            print('setting the updating flag');
            _isUpdating = false;
          });
        } catch (e) {
          setState(() {
            print('some error happened');
            _isUpdating = false;
          });
        }
      }
    });
  }

  Widget _firestoreToken() {
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

  Widget _intervalIndicators() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _circularAvartarIconButton(
                  Colors.blueAccent, Icons.free_breakfast),
              _circularAvartarIconButton(Colors.greenAccent, Icons.event_busy),
              _circularAvartarIconButton(Colors.orange, Icons.restaurant),
              _circularAvartarIconButton(Colors.pinkAccent, Icons.child_care)
            ],
          ),
        ),
      ),
    );
  }

  Widget _circularAvartarIconButton(Color backColor, IconData btnIcon) {
    return CircleAvatar(
      backgroundColor: backColor,
      child: IconButton(
        icon: Icon(
          btnIcon,
          color: Colors.white,
        ),
        disabledColor: Colors.red,
        onPressed: null,
      ),
    );
  }
}
