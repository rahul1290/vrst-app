import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrst/dbhelper.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:vrst/common/global.dart' as global;
import 'dart:convert';
import 'dart:io';

class LoginPage extends StatefulWidget {
  @override
    LoginPageState createState() {
    return LoginPageState();
  }
}

class _LoginData{
  String contactno = '';
  String password = '';
  String userType = 'Retailer';
}
bool loader = false;
class LoginPageState extends State<LoginPage> {
  final dbhelper = Databasehelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _LoginData _data = new _LoginData();

  bool _obscureText = true;
  // String _password;


  @override
  void initState() {
    loader = false;
    super.initState();
  }

  void _submit() async {
    print('_submit called');
    setState(() {
      //loader = true;
    });
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      String url = global.baseUrl+'login';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json = '{"contact": "'+_data.contactno +'","user_type": "'+ _data.userType +'", "password": "'+_data.password+'"}';
      http.Response response = await http.post(url, headers: headers, body: json);
      int statusCode = response.statusCode;
      if(statusCode == 200){
          Map body = jsonDecode(response.body);
          Map<String,dynamic> row = {
            Databasehelper.columnName : body['user_name'],
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
        //_showMyDialog();
        print('else called');
      }
    }else{
      setState(() {
        loader = false;
      });
      return;
    }
  }

  // Future<void> _showMyDialog() async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Authentication Alert!'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('Employee code or password not matched.'),
  //               Text('Please try again.'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: Text('Ok'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               setState(() {
  //                 loader = false;
  //               });
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  Future<bool> _onWillPop(){
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text('Want to exit?',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
        //content: new Text('',style:TextStyle(fontSize: 16),),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => exit(0),
            child: Text('Yes',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 16),),
          ),
          new FlatButton(
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
                                      icon: Icon(Icons.person,color:Colors.grey,),
                                      fillColor: Colors.blue,
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      labelText: 'Enter Contact Number',
                                    ),
                                    textCapitalization: TextCapitalization.words,
                                    cursorColor:Colors.black,
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter your Contact Number';
                                      }
                                      return null;
                                    },
                                    onSaved: (String value) {
                                      this._data.contactno= value;
                                    }
                                  ),
                                  TextFormField(
                                    key: Key('password'),
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.vpn_key,color:Colors.grey,),
                                      suffixIcon: GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      labelText: 'PASSWORD',
                                    ),
                                    cursorColor:Colors.black,
                                      //maxLength: 12,
                                    obscureText: _obscureText,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                    onSaved: (String value) {
                                      this._data.password = value;
                                    }
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      MaterialButton(
                                        onPressed: _submit,
                                        color: Colors.green[600],
                                        splashColor: Colors.red,
                                        child: Text('Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                      MaterialButton(
                                        onPressed: (){Navigator.pushNamed(context, '/loginwithotp'); },
                                        child: Text('Login With OTP',style: TextStyle(color: Colors.grey),),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Container(
                        child: MaterialButton(
                          onPressed: () {Navigator.pushNamed(context, '/register'); },
                          color: Color(0xFFf09a3e),
                          child: Text('SIGN UP',style: TextStyle(color:Colors.black),),
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