import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/common/drawer.dart';
import 'package:folding_cell/folding_cell.dart';
import 'dart:io';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _formKey = GlobalKey<FormState>();
  final _foldingCellKey = GlobalKey<SimpleFoldingCellState>();

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
              body: SimpleFoldingCell.create(
                  key: _foldingCellKey,
                  frontWidget: _buildFrontWidget(),
                  innerWidget: _buildInnerWidget(),
                  cellSize: Size(MediaQuery.of(context).size.width, 240),
                  padding: EdgeInsets.all(10),
                  animationDuration: Duration(milliseconds: 500),
                  borderRadius: 7,
                  onOpen: () => print('cell opened'),
                  onClose: () => print('cell closed'),
              ),
        ),
    );
  }

  Widget _buildFrontWidget() {
    return Container(
     // color: Color(0xFFffcd3c),
      decoration: BoxDecoration(
        color: const Color(0xFFf09a3e),
        // image: const DecorationImage(
        // image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0koOUaYFOw2cOOdDLpqtTU6telLyf7v6ZCQ&usqp=CAU'),
        // fit: BoxFit.fill,
        // ),
      ),
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              "HYBRID CHILLI SCHEME",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: 0,
            child: FlatButton(
              onPressed: () => _foldingCellKey?.currentState?.toggleFold(),
              child: Text(
                "VIEW",
              ),
              textColor: Colors.white,
              color: Colors.green,
              splashColor: Colors.white.withOpacity(0.5),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInnerWidget() {
    return Container(
      color: Color(0xFFecf2f9),
      padding: EdgeInsets.only(top: 10),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              "HYBRID CHILLI SCEHEME",
              style: TextStyle(
                color: Color(0xFF2e282a),
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child:Table(
                    // textDirection: TextDirection.rtl,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border:TableBorder.all(width: 1.0,color: Colors.black),
                    children: [
                      TableRow(
                          decoration: new BoxDecoration(
                              color: Colors.yellow
                          ),
                          children: [
                            Text("Srl. No.",textScaleFactor: 1.5,textAlign: TextAlign.left,),
                            Text("Sold Quantity in kg",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("Gift",textScaleFactor: 1.5,textAlign: TextAlign.center,),
                          ]
                      ),
                      TableRow(
                          children: [
                            Text("1",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("1 to 2 kg",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("15 Gm Silver Coin",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                          ]
                      ),
                      TableRow(
                          children: [
                            Text("2",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("2.1 to 4 kg",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("30 Gm Silver Coin",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                          ]
                      ),
                      TableRow(
                          children: [
                            Text("3",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("4.1 to 6 kg",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("60 Gm Silver Coin",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                          ]
                      ),
                      TableRow(
                          children: [
                            Text("4",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("6.1 to 9 kg",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("90 Gm Silver Coin",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                          ]
                      ),
                      TableRow(
                          children: [
                            Text("5",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("9.1 to 12 kg",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("1.5 Gm Gold Coin",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                          ]
                      ),
                      TableRow(
                          children: [
                            Text("6",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("12 kg & Above",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                            Text("2.5 Gm Gold Coin",textScaleFactor: 1.2,textAlign: TextAlign.center,),
                          ]
                      )
                    ],
                  ),

              ),
          Positioned(
            right: 5,
            bottom: 0,
            child: FlatButton(
              onPressed: () => _foldingCellKey?.currentState?.toggleFold(),
              child: Text(
                "Close",
              ),
              textColor: Colors.white,
              color: Colors.green,
              splashColor: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}