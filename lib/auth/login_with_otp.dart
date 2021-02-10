import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'dart:convert';
//import 'dart:io';
import 'package:vrst/common/global.dart' as global;
import 'package:http/http.dart' as http;

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

  void _submit() async {
    print('_submit called');
    setState(() {
      loader = true;
    });
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      String url = global.baseUrl+'generate-otp';
      //Map<String, String> headers = {"Content-type": "application/json"};
      http.Response response = await http.post(url,body:{'contact':_mobileNo});
      int statusCode = response.statusCode;
      // print(statusCode);
      // print(response.body);
      if(statusCode == 200){
        //Map body = jsonDecode(response.body);
        global.contactNo = _mobileNo;
        setState(() {
          loader = true;
        });
        Navigator.pushNamed(context, '/verifyotp');
        //Navigator.pushNamed(context, "/verifyotp",arguments: {"contact" : _mobileNo});
      } else {
        _showMyDialog();
      }
    }else{
      setState(() {
        loader = false;
      });
      return;
    }
  }


  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Authentication Alert!',textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Contact number not matched \n Please try again.',textAlign: TextAlign.center,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                //Navigator.of(context).pop();
                Navigator.pop(context);
                setState(() {
                  loader = false;
                });
              },
            ),
          ],
        );
      },
    );
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
                                child: Center(
                                  child: Text('Login with Mobile Number \n Enter your Mobile Number we will send you OTP to verify',textAlign: TextAlign.center,),
                                ),
                                padding: EdgeInsets.only(bottom: 10.0,top: 30.0),
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
                                        return 'Please enter your Contact number.';
                                      }
                                      if( value.length != 10){
                                        return 'Please enter valid Contact number.';
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
                          onPressed: _submit,
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