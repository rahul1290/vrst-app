import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:code_fields/code_fields.dart';
import 'package:vrst/dbhelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:io';
import 'package:vrst/common/global.dart' as global;

class Registerotp extends StatefulWidget {
  @override
  RegisterotpState createState() {
    return RegisterotpState();
  }
}

bool loader = false;
class RegisterotpState extends State<Registerotp> {
  final dbhelper = Databasehelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int codeLength = 4;
  String _otp;

  String validateCode(String code){
    if(code.length < codeLength) return "Please complete the code";
    else{
      bool isNumeric = int.tryParse(code) != null;
      if(!isNumeric) return "Please enter a valid code";
    }
    return null;
  }

  void _otpSubmit() async {
    print('_otpsubmit122');
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();

      String url = global.baseUrl+'registration-otp';
      print(url);
      //Map<String, String> headers = {"Content-type": "application/json"};
      http.Response response = await http.post(url,body:{'contact':global.contactNo,'otp':_otp});
      int statusCode = response.statusCode;
      print(statusCode);
      if(statusCode == 200){
        Map body = jsonDecode(response.body);
        Map<String,dynamic> row = {
          Databasehelper.columnName : body['user_name'],
          Databasehelper.columnState : body['state_id'],
          Databasehelper.columnContact : body['contact_no'],
          Databasehelper.columnkey : body['token'],
          Databasehelper.columnimage : '',
        };
        await dbhelper.insert(row);
        setState(() {
          loader = true;
        });
        Navigator.pushNamed(context, '/dashboard');
      } else {
        _showMyDialog();
      }
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OTP verification Alert!',textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('OTP not matched \n Please try again.',textAlign: TextAlign.center,),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Re-send OTP',style: TextStyle(color: Colors.amber),),
              onPressed: () {
                //Navigator.of(context).pop();
                Navigator.pop(context);
                setState(() {
                  loader = false;
                });
              },
            ),

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
  void initState() {
    loader = false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                      onChanged: (value){
                                        setState(() {
                                          _otp = value;
                                        });
                                      },
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
                          onPressed: _otpSubmit,
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
      );
  }
}