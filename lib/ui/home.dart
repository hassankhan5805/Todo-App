import 'package:flutter/material.dart';

import 'notodo.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('NoToDo'),
          backgroundColor: Colors.black54,
        ),
        body: new NoToDoScreen());
  }
}
