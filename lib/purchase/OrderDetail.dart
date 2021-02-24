import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vrst/dbhelper.dart';
import 'package:json_table/json_table.dart';
import 'package:flutter_html/flutter_html.dart';

class OrderDetail extends StatefulWidget {
  @override
  _OrderDetailState createState() => _OrderDetailState();
  final String orderId;
  OrderDetail(this.orderId);
}

class _OrderDetailState extends State<OrderDetail> {
  Map _orderDetail;
  final dbhelper = Databasehelper.instance;
  bool loader = true;

  @override
  void initState() {
    super.initState();
    _getOrderDetail();
  }

  void _getOrderDetail() async {
    List<dynamic> userdetail = await dbhelper.get(1);
    Map<String, String> headers = {"Content-type": "application/json","vrstKey": userdetail[0]['key']};
    String url = global.baseUrl + 'Purchase_ctrl/orderDetail/' + widget.orderId;
    print(url);
    http.Response resposne = await http.get(url,headers: headers);
    int statusCode = resposne.statusCode;
    print(statusCode);
    if (statusCode == 200) {
      setState(() {
        _orderDetail = jsonDecode(resposne.body);
        loader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Detail'),
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
                padding: const EdgeInsets.all(1.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bill No.',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(_orderDetail['order_info'][0]['bill_no'].toUpperCase()),
                          ],
                        ),
                        SizedBox(height: 8.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Distributor Name',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(_orderDetail['order_info'][0]['DealerName'].length > 20
                                ? _orderDetail['order_info'][0]['DealerName'].substring(0, 20)
                                : _orderDetail['order_info'][0]['DealerName']),
                          ],
                        ),
                        SizedBox(height: 8.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order Status',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(_orderDetail['order_info'][0]['bill_status']),
                          ],
                        ),
                        SizedBox(height: 8.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order Date',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(_orderDetail['order_info'][0]['created_at']),
                          ],
                        ),
                        SizedBox(height: 25.0,),
                        _orderDetail['order_detail'].toString().length > 2 ? JsonTable(
                          _orderDetail['order_detail'],
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
                        ) : Text('No Entries found.') ,
                        SizedBox(height: 10.0,),
                        RaisedButton(
                            onPressed: (){},
                            child: Text('Return Order'),
                        ),
                      ],
                    ),
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
