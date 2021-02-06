import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

class Loginwithotp extends StatefulWidget {
  @override
    LoginwithotpState createState() {
    return LoginwithotpState();
  }
}


bool loader = false;
class LoginwithotpState extends State<Loginwithotp> {
  //final dbhelper = Databasehelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _mobileNo;

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
                                padding: EdgeInsets.only(bottom: 30.0),
                              ),
                              Padding(
                                child: Text('Login with Mobile Number \n Enter your Mobile Number we will send you OTP to verify',),
                                padding: EdgeInsets.only(bottom: 10.0),
                              ),

                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                  TextFormField(
                                    key: Key('username'),
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.mobile_friendly,color:Colors.grey,),
                                      fillColor: Colors.blue,
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      labelText: 'Enter Contact Number',
                                    ),
                                    textCapitalization: TextCapitalization.words,
                                    cursorColor:Colors.black,
                                    //keyboardType: TextInputType.emailAddress,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter your Identity';
                                      }
                                      return null;
                                    },
                                    onSaved: (String value) {
                                      this._mobileNo = value;
                                    }
                                  ),
                                 
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Container(
                        child: MaterialButton(
                          onPressed: () {Navigator.pushNamed(context, '/verifyotp'); },
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