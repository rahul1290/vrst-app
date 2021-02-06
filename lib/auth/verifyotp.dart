import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:code_fields/code_fields.dart';
//import 'package:ibcportal/dbhelper.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
//import 'package:ibcportal/common/global.dart' as global;

class Verifyotp extends StatefulWidget {
  @override
    VerifyotpState createState() {
    return VerifyotpState();
  }
}

class _LoginData{
  String identity = '';
  String password = '';
}
bool loader = false;
class VerifyotpState extends State<Verifyotp> {
  //final dbhelper = Databasehelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _LoginData _data = new _LoginData();
  final int codeLength = 4;

  String validateCode(String code){
    if(code.length < codeLength) return "Please complete the code";
    else{
      bool isNumeric = int.tryParse(code) != null;
      if(!isNumeric) return "Please enter a valid code";
    }
    return null;
  }

  bool _obscureText = true;
  String _password;

  @override
  void initState() {
    loader = false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: _onWillPop,
      child: Scaffold(
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
            ):Container(
                //decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: SingleChildScrollView(
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: [
                            Container(
                          padding: EdgeInsets.all(20.0),
                          child : Column(
                            children: <Widget>[
                              Container(
                                child: Image.asset('assets/images/vnr-logo.png'),
                              ),
                              
                              Padding(
                                child: Text('Verification',
                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                                padding: EdgeInsets.only(bottom: 10.0,top: 30.0),
                              ),
                              Padding(
                                child: Text('Enter OTP code sent to your number.',),
                                padding: EdgeInsets.only(bottom: 20.0),
                              ),

                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    CodeFields(
                                      length: codeLength,
                                      validator: validateCode,
                                      inputDecoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(0.2),
                                        
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24.0),
                                          borderSide: BorderSide(color: Colors.transparent)
                                        ),

                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24.0),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Container(
                        child: MaterialButton(
                          onPressed: () {Navigator.pushNamed(context, '/dashboard'); },
                          //color: Color(0xFFf09a3e),
                          shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Color(0xFFf09a3e))
                                ),
                          child: Text('Continue',style: TextStyle(color:Colors.black),),
                        ),
                      )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
            )
      ),
    );
  }
}