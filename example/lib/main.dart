import 'package:android_long_task/android_long_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_service_config.dart';

AppServiceData data = AppServiceData();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'my foreground service example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'android long task example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = 'result';
  String _status = 'status';

  @override
  void initState() {
    AppClient.observe.listen((json) {
      var serviceData = AppServiceData.fromJson(json);
      setState(() {
        _status = serviceData.notificationDescription;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_status', textAlign: TextAlign.center),
            SizedBox(height: 20),
            Text('$_result', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6),
            RaisedButton(
              onPressed: () async {
                try {
                  await AppClient.execute(data);
                  setState(() => _result = 'executing service');
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
              child: Text('run dart function'),
            ),
            // RaisedButton(
            //   onPressed: () async {
            //     try {
            //       data.progress = 0;
            //       await AppClient.setInitialData(data);
            //       setState(() {
            //         _result = 'set data';
            //       });
            //     } on PlatformException catch (e, stacktrace) {
            //       print(e);
            //       print(stacktrace);
            //     }
            //   },
            //   child: Text('set initial service data'),
            // ),
            RaisedButton(
              onPressed: () async {
                try {
                  var result = await AppClient.getData();
                  setState(() => _result = result.toString());
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
              child: Text('get service data'),
            ),
            // RaisedButton(
            //   onPressed: () async {
            //     try {
            //       await AppClient.startService();
            //       setState(() => _result = 'start service');
            //     } on PlatformException catch (e, stacktrace) {
            //       print(e);
            //       print(stacktrace);
            //     }
            //   },
            //   child: Text('start service'),
            // ),
            RaisedButton(
              onPressed: () async {
                try {
                  await AppClient.stopService();
                  setState(() => _result = 'stop service');
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
              child: Text('stop service'),
            ),

          ],
        ),
      ),
    );
  }
}

serviceMain() async {
  // print(arg);
  WidgetsFlutterBinding.ensureInitialized();
  ServiceClient.setExecutionCallback((initialData) async {
    var serviceData = AppServiceData.fromJson(initialData);
    for (var i = 0; i < 100; i++) {
      print('dart -> $i');
      data.progress = i;
      var result2 = await ServiceClient.update(data);
      if (i > 50) {
        var result = await ServiceClient.stopService();
        print(result);
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  });
}