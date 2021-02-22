import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vrst/dbhelper.dart';
import 'package:json_table/json_table.dart';
import 'package:flutter_html/flutter_html.dart';

class SchemeDetail extends StatefulWidget {
  @override
  _SchemeDetailState createState() => _SchemeDetailState();
  final String schemeId;
  SchemeDetail(this.schemeId);
}

class _SchemeDetailState extends State<SchemeDetail> {
  Map _schemesDetail;
  final dbhelper = Databasehelper.instance;
  bool loader = true;

  @override
  void initState() {
    super.initState();
    _getSchemesDetail();
  }

  void _getSchemesDetail() async {
    String url = global.baseUrl + 'scheme-detail/' + widget.schemeId;
    http.Response resposne = await http.get(url);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _schemesDetail = jsonDecode(resposne.body);
        loader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheme Detail'),
        centerTitle: true,
      ),
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
            ) :Center(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        Text(_schemesDetail['scheme'][0]['heading'].toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 10.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Lifting Period'),
                            Text('01-04-2019 to 31-03-2020',
                                style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0,),
                        JsonTable(
                          _schemesDetail['schemeDetail'],
                          tableHeaderBuilder: (String header) {
                            return Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0.5),
                                  color: Colors.grey[300]),
                              child: Text(
                                header,
                                textAlign: TextAlign.center,
                                //style: Theme.of(context).accentColorBrightness,
                              ),
                            );
                          },
                          tableCellBuilder: (value) {
                            return Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5, color: Colors.grey.withOpacity(0.5))),
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16.0),
                                //style: Theme.of(context).textTheme.display1.copyWith(fontSize: 14.0, color: Colors.grey[900]),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10.0,),
                        Html(
                          data: _schemesDetail['scheme'][0]['instruction'],
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
        ),
      ),
    );
  }
}
