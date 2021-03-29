import 'dart:async';
import 'package:flutter/material.dart';
import 'chart.dart';
import 'file:///D:/flutter_projects/vrst/lib/auth/register.dart';
import 'package:vrst/auth/loginpage.dart';
import 'package:vrst/auth/login_with_otp.dart';
import 'package:vrst/auth/registerotp.dart';
import 'package:vrst/auth/verifyotp.dart';
import 'package:vrst/dashboard.dart';
import 'package:vrst/dbhelper.dart';
import 'package:vrst/purchase/OrderList.dart';
import 'package:vrst/purchase/Purchase.dart';
import 'package:vrst/returnOrder/returnList.dart';
import 'package:vrst/returnOrder/returnorder.dart';
import 'package:vrst/purchase/billEntryForm.dart';
import 'package:vrst/auth/profile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VRST',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splashscreen(),
        '/login' : (context) => LoginPage(),
        '/loginwithotp' : (context) => Loginwithotp(),
        '/verifyotp': (context) => Verifyotp(),
        '/register': (context) => Register(),
        '/registerotp' : (context) => Registerotp(),
        '/dashboard' : (context) =>  Dashboard(),
        '/purchase' : (context) => Purchase(),
        '/returnOrder' : (context) => ReturnOrder(),
        '/billEntryForm' : (context) => BillEntryForm(),
        '/profile' : (context) => Profilepage(),
        '/orderList' : (context) => OrderList(),
        '/returnlist' : (context) => Returnlist(),
        '/chart' : (context) => Chart(),
      },
    );
  }
}

class Splashscreen extends StatefulWidget {
  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final dbhelper = Databasehelper.instance;

  @override
  // ignore: must_call_super
  void initState() {
    // TODO: implement initState
    Timer(Duration(seconds: 3), nextPage);
  }


  void nextPage() async {
      List list = await dbhelper.getall();
      print('nextPage called.');
      print(list.length);
      if(list.length == 0){
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, "/dashboard");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            //decoration: BoxDecoration(color: Colors.blueAccent),
            decoration: BoxDecoration(color: Color(0xFFf09a3e)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white30,
                        radius: 65.0,
                        child: Image.asset('assets/images/vnr-logo.png'),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20.0),),
                      Text('VRST',style: TextStyle(color: Colors.white,fontSize: 22.0,fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    CircularProgressIndicator(backgroundColor: Colors.white,),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text("Powered by VNR SEEDS",style: TextStyle(color: Colors.black),)
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
