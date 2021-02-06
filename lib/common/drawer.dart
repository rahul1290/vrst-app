import 'package:flutter/material.dart';
import 'dart:io';
import 'package:vrst/dbhelper.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
final dbhelper = Databasehelper.instance;

Future<void> logout() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You want to logout?'),
          content: SingleChildScrollView(
//            child: ListBody(
//              children: <Widget>[
//                Text('Are you sure to logout'),
//              ],
//            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes',style: TextStyle(color: Colors.red),),
              onPressed: () {
                    dbhelper.deletedata();
                    Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            FlatButton(
              child: Text('No'),
              color: Colors.green,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('global.uname'),
            accountEmail: Text('global.emailId'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage('https://www.clipartmax.com/png/middle/29-291264_person-clipart-person-clip-art-image-clip-art-library-hypertext-transfer-protocol.png'),
            ),
             otherAccountsPictures: <Widget>[
               CircleAvatar(
                 backgroundColor: Colors.green,
                 child: Text('X'),
               )
             ],
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Dashboard'),
            //trailing: Icon(Icons.arrow_forward_ios),
            onTap: (){
              Navigator.pushReplacementNamed(context, "/dashboard");
            },
          ),
          ListTile(
            leading: Icon(Icons.add_shopping_cart_outlined,color: Colors.green,),
            title: Text('Purchase Order'),
            onTap: (){
              Navigator.pushNamed(context, '/purchase');
            },
          ),
          ListTile(
            leading: Icon(Icons.remove_shopping_cart_outlined, color: Colors.orange,),
            title: Text('Return Order'),
            onTap: () => Navigator.pushNamed(context, '/purchase_old'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Logout'),
            onTap: (){
              logout();
            },
          ),
        ],
      ),
    );
  }
}
