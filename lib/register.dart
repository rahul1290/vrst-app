import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrst/common/global.dart' as global;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = 'Select State';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(global.projectTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        
                        DropdownButton<String>(
                          value: dropdownValue ?? null,
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          isExpanded: true,
                          hint: Text('Select State'),
                          items: <String>['Select State','One', 'Two', 'Free', 'Four']
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                        ),

                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter Retailer Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter Contact Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter EmailID (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter PAN/Aadhar (Optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          color: Colors.lightGreen,
                          splashColor: Colors.red,
                          child: Text('NEXT',style: TextStyle(color: Colors.white, fontSize: 16),),
                          onPressed: (){}
                        ),
                      ],
                    ),
                  ), 
                ), 
              ],
            ),
          ),
      ),
      ), 
       
    );
  }
}