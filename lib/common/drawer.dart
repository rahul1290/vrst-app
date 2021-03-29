import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:vrst/common/global.dart' as global;
import 'package:vrst/dbhelper.dart';
import 'package:http/http.dart' as http;

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
final dbhelper = Databasehelper.instance;
String _uname = '';
String _uemail = '';
String _uimage;
File _image;


@override
// ignore: must_call_super
void initState() {
  // TODO: implement initState
  fetchData().then((value){
    urlToFile();
  });
}

Future fetchData() async{
  List userData = await dbhelper.getall();
  print(userData);
  setState(() {
    _uname = userData[0]['name'];
    _uemail = userData[0]['contact'];
    _uimage = userData[0]['image'];
  });
}

void urlToFile() async {
    print(global.baseUrl+'../assets/images/userprofile/'+ _uimage +'.jpg');
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');
    http.Response response = await http.get(global.baseUrl+'../assets/images/userprofile/'+ _uimage +'.jpg');
    await file.writeAsBytes(response.bodyBytes);
      if(response.statusCode == 200){
        setState(() {
          _image = file;
        });
      }
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
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: _image != null ? ClipRRect(
                        borderRadius:
                        BorderRadius.circular(100),
                        child: Image.file(
                          _image,
                          width: 300,
                          height: 300,
                          fit: BoxFit.fill,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:
                                BorderRadius.circular(100)),
                        width: 300,
                        height: 300,
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.grey[800],
                        ),
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
              //Navigator.pushReplacementNamed(context, "/purchase");
              
            },
          ),
          ListTile(
            leading: Icon(Icons.add_shopping_cart_outlined,color: Colors.green,),
            title: Text('New Order'),
            onTap: (){
              Navigator.pushNamed(context, '/billEntryForm');
              //Navigator.pushNamed(context, '/Test');

            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag_outlined,color: Colors.purpleAccent,),
            title: Text('My Order\'s'),
            onTap: (){
              Navigator.pushNamed(context, '/orderList');
              //Navigator.pushNamed(context, '/Test');
            },
          ),

          ListTile(
            leading: Icon(Icons.assignment_return,color: Colors.red,),
            title: Text('Return order\'s'),
            onTap: (){
              Navigator.pushNamed(context, '/returnlist');

            },
          ),

          ListTile(
            leading: Icon(Icons.auto_stories,color: Colors.blueAccent,),
            title: Text('Purchase Report'),
            onTap: (){
              //Navigator.pushNamed(context, '/returnlist');
              Navigator.pushNamed(context, '/chart');
            },
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
