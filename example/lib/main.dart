import 'package:android_long_task/android_long_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_service_config.dart';
import 'LocalNotification.dart';



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
            Text('$_result',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6),
            ElevatedButton(
              child: Text('run dart function'),
              onPressed: () async {
                // This code starts the foreground service
                try {
                  var result = await AppClient.execute(data);
                  var resultData = AppServiceData.fromJson(result);
                  setState(() => _result =
                      'finished executing service process ;) -> ${resultData.progress}');
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
            ),
            ElevatedButton(
              child: Text('get service data'),
              onPressed: () async {
                try {
                  var result = await AppClient.getData();
                  setState(() => _result = result.toString());
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
            ),
            ElevatedButton(
              child: Text('stop service'),
              onPressed: () async {
                try {
                  await AppClient.stopService();
                  setState(() => _result = 'stop service');
                } on PlatformException catch (e, stacktrace) {
                  print(e);
                  print(stacktrace);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

//this entire function runs in your ForegroundService
//needs this pragma to run in release mode
//function name may be defined in AppService.kt?
@pragma('vm:entry-point')
serviceMain() async {
  // print(arg);
  WidgetsFlutterBinding.ensureInitialized();

  //if your use dependency injection you initialize them here
  //what ever objects you created in your app main function is not accessible here

  //set a callback and define the code you want to execute when your ForegroundService runs

  ServiceClient.setExecutionCallback((initialData) async {
    //you set initialData when you are calling AppClient.execute()
    //from your flutter application code and receive it here
    var serviceData = AppServiceData.fromJson(initialData);

    for (var i = 0; i < 100; i++) {
      var notification = LocalNotification();
      notification.showNotificationWithoutSound("From background service", "progress: $i");

      print('dart -> $i');
      data.progress = i;
      var result2 = await ServiceClient.update(data);

      if (i > 10) {
        // end the execute() that started the foreground service
        await ServiceClient.endExecution(data);

        // stop foreground service itself
        var result = await ServiceClient.stopService();
        print(result);
      }

      // sleep a bit
      await Future.delayed(const Duration(seconds: 10));
    }
  });
}
