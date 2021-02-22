import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/common/drawer.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vrst/dbhelper.dart';
import 'package:vrst/schemeDetail.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List _schemes = List();
  final dbhelper = Databasehelper.instance;
  bool loader = true;

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Want to exit?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            //content: new Text('',style:TextStyle(fontSize: 16),),
            actions: <Widget>[
              FlatButton(
                onPressed: () => exit(0),
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: Color(0xFFf09a3e),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
                color: Colors.green,
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    _getSchemes();
  }

  void _getSchemes() async {
    List<dynamic> userdetail = await dbhelper.get(1);
    String url = global.baseUrl + 'all-scheme/' + userdetail[0]['state'];
    print(url);
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _schemes = jsonDecode(resposne.body);
        loader = false;
      });
    }
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
        body: loader ? Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 15.0,),
                Text('  Loading...',style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold,),),
              ],
            ),
          ),
          //child: CircularProgressIndicator(),
        ) : ListView.builder(
          itemCount: _schemes.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top:4.0),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(_schemes[index]['heading'].substring(0, 1)),
                      ),
                      //trailing: Icon(Icons.arrow_forward_ios_sharp),
                      title: Text(_schemes[index]['heading']),
                      subtitle: Text(_schemes[index]['subheading'].length > 100
                          ? _schemes[index]['subheading'].substring(0, 100)
                          : _schemes[index]['subheading']),
                    ),
                    ButtonBar(
                      children: [
                        RaisedButton(
                          color: Color(0xFFf09a3e),
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text('View Detail',style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SchemeDetail(_schemes[index]['scheme_id'].toString())),
                              );
                          },
                        ),
                       
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
