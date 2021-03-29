import 'package:flutter/material.dart';
import 'package:vrst/common/drawer.dart';
import 'package:vrst/dbhelper.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:json_table/json_table.dart';

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  final dbhelper = Databasehelper.instance;

  List _chartData;
  bool loader;

  @override
  void initState() {
    super.initState();
    _getChartData();
  }

  Future _getChartData() async {
    setState(() {
      loader = true;
    });
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = {
      "Content-type": "application/x-www-form-urlencoded",
      "vrstKey": userdetail[0]['key']
    };
    String url = global.baseUrl + 'Purchase_ctrl/purchase_report/';
    print(url);
    http.Response resposne = await http.get(url, headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _chartData = jsonDecode(resposne.body);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
        centerTitle: true,
      ),
      drawer: DrawerPage(),
      body: loader
          ? Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      '  Loading...',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              //child: CircularProgressIndicator(),
            )
          : Center(
              child: RefreshIndicator(
                onRefresh: _getChartData,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        JsonTable(_chartData, showColumnToggle: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}