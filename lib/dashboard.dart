import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/common/drawer.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> _onWillPop(){
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Want to exit?',textAlign: TextAlign.center,style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 16),),
        //content: new Text('',style:TextStyle(fontSize: 16),),
        actions: <Widget>[
          FlatButton(
            onPressed: () => exit(0),
            child: Text('Yes',style: TextStyle(color: Color(0xFFf09a3e),fontWeight: FontWeight.bold,fontSize: 16),),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
            color: Colors.green,
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
              appBar: AppBar(
              title: Text('DASHBOARD'),
              centerTitle: true,
              ),
              drawer: DrawerPage(),
              body: Center(
                child: Text('Dashboard.'),
              ),
      ),
    );
  }
}