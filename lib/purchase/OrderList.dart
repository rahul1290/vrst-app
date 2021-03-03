import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/common/drawer.dart';
//import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vrst/dbhelper.dart';
import 'package:vrst/purchase/OrderDetail.dart';
//import 'package:vrst/schemeDetail.dart';

class OrderList extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List _orders = List();
  final dbhelper = Databasehelper.instance;
  bool loader = true;

  @override
  void initState() {
    super.initState();
    _getOders();
  }

  void _getOders() async {
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = {"Content-type": "application/json","vrstKey": userdetail[0]['key']};
    String url = global.baseUrl + 'Purchase_ctrl/my_order';
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    if (statusCode == 200) {
      setState(() {
        _orders = jsonDecode(resposne.body);
        loader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Order\'s'),
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
        ) :
        ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top:4.0),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      // leading: CircleAvatar(
                      //   child: Text(_orders[index]['bill_no'].substring(0, 1)),
                      // ),
                      //trailing: Icon(Icons.arrow_forward_ios_sharp),
                      title: Text("Bill No.: " + _orders[index]['bill_no']),
                      subtitle: Text("Distributor: "+ _orders[index]['DealerName'] + "\nOrder Date: "+ _orders[index]['created_at']+"\nStatus: "+_orders[index]['bill_status']),
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
                                  builder: (context) => OrderDetail(_orders[index]['bill_id'].toString())),
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
        
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_shopping_cart),
          backgroundColor: Colors.redAccent,
          onPressed: () {
            Navigator.pushNamed(context, '/billEntryForm');
          },
        ),
      );
  }
}
