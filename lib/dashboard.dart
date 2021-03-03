import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/common/drawer.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vrst/dbhelper.dart';
import 'package:vrst/schemeDetail.dart';
import 'package:blinking_text/blinking_text.dart';

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
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'all-scheme/' + userdetail[0]['state'];
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _schemes = jsonDecode(resposne.body);
        loader = false;
      });
    } else {
      print('else');
      setState(() {
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
        ) : _schemes.length > 0 ? ListView.builder(
          itemCount: _schemes.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      // leading: CircleAvatar(
                      //   child: Text(_schemes[index]['heading'].substring(0, 1)),
                      // ),
                      title: Text(_schemes[index]['heading']),
                      subtitle: Text(_schemes[index]['subheading'].length > 100 ? _schemes[index]['subheading'].substring(0, 100) : _schemes[index]['subheading']),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.only(left:16.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            _schemes[index]['claim'] != null ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Eligible For : ',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                                BlinkText(
                                _schemes[index]['claim'].toString().toUpperCase(),
                                style: TextStyle(fontSize: 16.0, color: Colors.green),
                                beginColor: Colors.black,
                                endColor: Colors.green,
                                times: 10,
                                duration: Duration(seconds: 2),
                              ),
                              ],
                            ),
                            ) : Text(''),
                            
                            SizedBox(height: 6.0,),
                            _schemes[index]['next'] != null ?
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Next to Close : ',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                                  BlinkText(
                                  _schemes[index]['next'].toString().toUpperCase(),
                                  style: TextStyle(fontSize: 16.0, color: Colors.red),
                                  beginColor: Colors.black,
                                  endColor: Colors.red,
                                  times: 10,
                                  duration: Duration(seconds: 1),
                                ),
                                ],
                              ),
                              ) : Text(''),
                            
                            
                          ],
                        ), 
                      ),
                    ),
                    
                    ButtonBar(
                      children: [
                        RaisedButton(
                          color: Color(0xFFf09a3e),
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text('View Scheme Detail',style: TextStyle(color: Colors.white),),
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
        ) : Center(
          child: Text('No scheme available.'),
        ),
      ),
    );
  }
}
