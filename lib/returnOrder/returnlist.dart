import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/common/drawer.dart';
// import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vrst/dbhelper.dart';
// import 'package:vrst/schemeDetail.dart';
// import 'package:blinking_text/blinking_text.dart';

class Returnlist extends StatefulWidget {
  @override
  _ReturnlistState createState() => _ReturnlistState();
}

class _ReturnlistState extends State<Returnlist> {
  List _returnList = List();
  final dbhelper = Databasehelper.instance;
  bool loader = true;

  @override
  void initState() {
    super.initState();
    _getRetunOrders();
  }

  void _getRetunOrders() async {
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = { "Content-type": "application/x-www-form-urlencoded","vrstKey": userdetail[0]['key'] };
    String url = global.baseUrl + 'Purchase_ctrl/return_order/';
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _returnList = jsonDecode(resposne.body);
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
          title: Text('Return Order\'s'),
          centerTitle: true,
        ),
        drawer: DrawerPage(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/returnOrder'),
          child: Icon(Icons.assignment_return_outlined),
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
        ) : _returnList.length > 0 ? ListView.builder(
          itemCount: _returnList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0,right: 8.0),
              child: Card(
                color: _returnList[index]['distributor_status'] == 'Pending' ? Colors.orange[50] : Colors.green[50],
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Table(  
                    //defaultColumnWidth: FixedColumnWidth(100.0),  
                    // border: TableBorder.all(  
                    //     color: Colors.black,  
                    //     style: BorderStyle.solid,  
                    //     width: 1),  
                    children: [  
                      TableRow( children: [  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text('CropName', style: TextStyle(fontSize: 18.0))]),  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text(': '+_returnList[index]['CropName'])]), 
                      ]),  
                      TableRow( children: [  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text('CropVariety',style: TextStyle(fontSize: 18.0))]),  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text(': '+_returnList[index]['ProductName'])]),  
                      ]),  
                      TableRow( children: [  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text('Qty',style: TextStyle(fontSize: 18.0),textAlign: TextAlign.start,)]),  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text(': '+_returnList[index]['qty'] + ' gm')]),
                      ]),
                      TableRow( children: [  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text('Distributor',style: TextStyle(fontSize: 18.0),textAlign: TextAlign.start,)]),  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text(': '+_returnList[index]['DealerName'])]),
                      ]),
                      TableRow( children: [  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text('Date',style: TextStyle(fontSize: 18.0),textAlign: TextAlign.start,)]),  
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[Text(': '+_returnList[index]['created_at'])]),
                      ]),
                      TableRow( 
                        children: [  
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Text('Status',style: TextStyle(fontSize: 18.0),textAlign: TextAlign.start,)
                              ]
                            ),  
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Text(': '+_returnList[index]['distributor_status'])
                              ]
                            ),
                        ]
                      ),  
                    ],  
                  ),
                      ),
                    ),
                    // ListTile(
                    //   // leading: CircleAvatar(
                    //   //   child: Text(_schemes[index]['heading'].substring(0, 1)),
                    //   // ),
                    //   title: Text(_returnList[index]['DealerName']),
                    //   subtitle: Text(_returnList[index]['retailer_id'].length > 100 ? _returnList[index]['retailer_id'].substring(0, 100) : _returnList[index]['retailer_id']),
                    // ),
                  ],
                ),
              ),
            );
          },
        ) : Center(
          child: Text('No Return orders.'),
        ),
      );
  }
}
