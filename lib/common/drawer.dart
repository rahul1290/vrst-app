import 'package:flutter/material.dart';
import 'dart:io';
import 'package:vrst/dbhelper.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
final dbhelper = Databasehelper.instance;
String _uname = '';
String _uemail = '';


@override
void initState() {
  // TODO: implement initState
  fetchData();
}

void fetchData() async{
  List userData = await dbhelper.getall();
  setState(() {
    _uname = userData[0]['name'];
    _uemail = userData[0]['contact'];
  });
}

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
            accountName: Text(_uname),
            accountEmail: Text(_uemail),
            // currentAccountPicture: CircleAvatar(
            //   backgroundColor: Colors.white54,
            //   backgroundImage: NetworkImage('https://www.vnrseeds.co.in/hrims/images/LogoNew.png',scale:1),
            // ),
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                'https://www.vnrseeds.co.in/hrims/images/LogoNew.png',
                height: 150.0,
                width: 100.0,
              ),
            ),
             otherAccountsPictures: <Widget>[
               GestureDetector(
                 child: CircleAvatar(
                   backgroundColor: Colors.white54,
                   minRadius: 2.0,
                   child: Icon(
                     Icons.edit_outlined
                   ),
                 ),
                 onTap: () => Navigator.pushReplacementNamed(context, "/profile"),
               ),
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
              Navigator.pushNamed(context, '/billEntryForm');
              //Navigator.pushNamed(context, '/Test');

            },
          ),
          ListTile(
            leading: Icon(Icons.add_shopping_cart_outlined,color: Colors.green,),
            title: Text('OrderList'),
            onTap: (){
              //Navigator.pushNamed(context, '/orderList');
              Navigator.pushNamed(context, '/Test');
            },
          ),
          ListTile(
            leading: Icon(Icons.remove_shopping_cart_outlined, color: Colors.orange,),
            title: Text('Return Order'),
            onTap: () => Navigator.pushNamed(context, '/returnOrder'),
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
