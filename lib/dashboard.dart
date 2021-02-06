import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/common/drawer.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = 'Select State';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DASHBOARD'),
        centerTitle: true,
      ),
      drawer: DrawerPage(),
      body: Center(
        child: Text('Dashboard.'),
      ), 
       
    );
  }
}