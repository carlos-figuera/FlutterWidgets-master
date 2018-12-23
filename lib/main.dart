import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:intl/intl.dart';
import 'model/products_repository.dart';
import 'model/product.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
FlutterWebviewPlugin flutterWebviewPlugin = FlutterWebviewPlugin();


//Instancias para notificaciones
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
var initializationSettingsAndroid =
new AndroidInitializationSettings('@mipmap/ic_launcher');
var initializationSettingsIOS = new IOSInitializationSettings();
var initializationSettings = new InitializationSettings(
    initializationSettingsAndroid, initializationSettingsIOS);




void main() => runApp(MaterialApp(
      home: WebViewExample(),
      debugShowCheckedModeBanner: false,
    ));


//Webview principal
class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  TextEditingController controller = TextEditingController();

  var urlString = "https://www.acceso-one.com";

  launchUrl() {
    setState(() {
      urlString = controller.text;
      flutterWebviewPlugin.reloadUrl(urlString);
    });
  }

  _ocultar() {
    setState(() {
      flutterWebviewPlugin.hide();

    });
  }

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin= new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);




    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged wvs) {


          if (wvs.type.toString()=="WebViewState.startLoad") {
            print( wvs.type);
            flutterWebviewPlugin.hide();
      }else if (wvs.type.toString()=="WebViewState.finishLoad") {
            print( wvs.type);
        flutterWebviewPlugin.show();
      }


    });

  }

  @override
  void dispose() {
    super.dispose();
    flutterWebviewPlugin.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        leading:null,
        title: TextField(
          autofocus: false,
          controller: controller,
          textInputAction: TextInputAction.go,
          onSubmitted: (url) => launchUrl(),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabled: true,
            hintText: "Acceso One ",
            hintStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () {
              showNotification();
                   _ocultar();
            },

          ),
          Text(
            "1",
            maxLines: 1,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
      url: urlString,
      withZoom: false,
      withJavascript: true,
      hidden: true,
    );
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen() ),
    );
  }


  showNotification() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item id 2');

  }

}


//Notificaciones   en gribvIEW
class WebViewExample1 extends StatefulWidget {
  @override
  _WebViewExampleState1 createState() => _WebViewExampleState1();
}

class _WebViewExampleState1 extends State<WebViewExample1> {
  @override


  Widget build(BuildContext context) {
    List<Card> _buildGridCards(int count) {
      List<Card> cards = List.generate(
        count,
            (int index) => Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 18.0 / 11.0,
                child: Image.asset('assets/diamante.jpg'),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Title'),
                    SizedBox(height: 8.0),
                    Text('Secondary Text'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      return cards;
    }
    List<Card> _buildGridCards1(BuildContext context) {
      List<Product> products = ProductsRepository.loadProducts(Category.all);

      if (products == null || products.isEmpty) {
        return const <Card>[];
      }

      final ThemeData theme = Theme.of(context);
      final NumberFormat formatter = NumberFormat.simpleCurrency(
          locale: Localizations.localeOf(context).toString());

      return products.map((product) {
        return Card(
          // TODO: Adjust card heights (103)
          child: Column(
            // TODO: Center items on the card (103)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 18 / 11,
                child: Image.asset(
                  'assets/diamante.jpg'),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: Column(
                    // TODO: Align labels to the bottom and center (103)
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // TODO: Change innermost Column (103)
                    children: <Widget>[
                      // TODO: Handle overflowing labels (103)
                      Text(
                        product.name,
                        style: theme.textTheme.title,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        formatter.format(product.price),
                        style: theme.textTheme.body2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("notificaciones"),
        leading: IconButton(
        icon: Icon(
        Icons.arrow_back,
        semanticLabel: 'menu',
    ),
    onPressed: () {
      Navigator.pop(context,
          MaterialPageRoute(builder: (context) => WebViewExample()));
      flutterWebviewPlugin.show();
  },   ), actions: <Widget>[

          IconButton(
              icon: Icon(
                Icons.date_range,
                semanticLabel: "serach",
              ),
              onPressed: () {

              }),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 9.0 / 9.4,
        children: _buildGridCards1(context),
      ),
    );
  }
}


//Segunda actividad sencilla

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("notificaciones"),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.date_range,
                semanticLabel: "serach",
              ),
              onPressed: () {}),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0,
        children: <Widget>[Card()],
      ),
    );
  }
}



//ejemplo  peticion http
class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  List widgets = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sample App"),
        ),
        body: ListView.builder(
            itemCount: widgets.length,
            itemBuilder: (BuildContext context, int position) {
              return getRow(position);
            }));
  }

  Widget getRow(int i) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Text("Row ${widgets[i]["title"]}")
    );
  }







  loadData() async {
    String dataURL = "https://jsonplaceholder.typicode.com/posts";
    http.Response response = await http.get(dataURL);
    setState(() {
      widgets = json.decode(response.body);
    });
  }
}



//  petiones  con  un listView y progreView
class SampleAppPage1 extends StatefulWidget {
  SampleAppPage1({Key key}) : super(key: key);

  @override
  _SampleAppPageState1 createState() => _SampleAppPageState1();
}

class _SampleAppPageState1 extends State<SampleAppPage1> {
  List widgets = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  showLoadingDialog() {
    return widgets.length == 0;
  }

  getBody() {
    if (showLoadingDialog()) {
      return getProgressDialog();
    } else {
      return getListView();
    }
  }

  getProgressDialog() {
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Notificaciones"),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                semanticLabel: "serach",
              ),
              onPressed: () {  Navigator.pop(context,
                  MaterialPageRoute(builder: (context) => WebViewExample()));
              flutterWebviewPlugin.reload();}),
        ),
        body: getBody());
  }

  ListView getListView() => ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int position) {
        return getRow(position);
      });

  Widget getRow(int i) {

   // return Padding(padding: EdgeInsets.all(10.0), child: Text("Row ${widgets[i]["title"]}"));





    return Card(
        child: Padding( padding: EdgeInsets.all(16.0),
        child: Row(


          children: <Widget>[
            Expanded(
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("titulo ${widgets[i]["id"]}"),

                    SizedBox(height: 8.0),

                    Text("cuerpoR:  ${widgets[i]["body"]}",textAlign: TextAlign.justify,),

                  ],
                )),
            IconButton(
                icon: Icon(
                  Icons.delete,
                  semanticLabel: "serach",

                ),
                onPressed: () {print( "$i  " );}),
          ],
        )));




  }

  loadData() async {
    String dataURL = "https://jsonplaceholder.typicode.com/posts";
    http.Response response = await http.get(dataURL);
    setState(() {
      widgets = json.decode(response.body);
    });
  }
}









