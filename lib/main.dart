import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());
const stripe_publishable_key = 'pk_test_8SO0xvg81PReOLXk540YH09G';
const stripe_secret_key = 'sk_test_MuXP7Z58vO4zx8NPuRW2NzTv';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = "";

  checkstatus(sessionid) {
    Map<String, String> headers = {
      "Content-type": "application/json",
      'Authorization': 'Bearer $stripe_secret_key'
    };

    http
        .get('https://api.stripe.com/v1/checkout/sessions/$sessionid',
            headers: headers)
        .then((response) {
      print(response.body);
      Map json = jsonDecode(response.body);
      if (json['customer'] != null) {
        // payment successful, top up the quantity
        setState(() {
          _message = response.body;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  String selectedSku;
  selectsku(sku) {
    print(sku);
    setState(() {
      selectedSku = sku;
    });
  }

  @override
  Widget build(BuildContext bc) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stripe App Example'),
        ),
        body: ListView(
          children: <Widget>[
            RadioListTile(
              value: 'sku_Gt6Fd6L4tzklsI',
              groupValue: selectedSku,
              onChanged: selectsku,
              title: Text('RM 10'),
            ),
            RadioListTile(
              value: 'sku_Gt6FCvq5TvWRRm',
              groupValue: selectedSku,
              onChanged: selectsku,
              title: Text('RM 50'),
            ),
            RadioListTile(
              value: 'sku_Gt5RKZEpBfuYQF',
              groupValue: selectedSku,
              onChanged: selectsku,
              title: Text('RM 100'),
            ),
            RaisedButton(
              child: Text("PAY"),
              onPressed: () async {
                setState(() {
                  _message = '';
                });
                // payment page
                final sessionId = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => PaymentPage(sku: selectedSku),
                        fullscreenDialog: true));
                if (sessionId is String) {
                  checkstatus(sessionId);
                }
              },
            ),
            Text(_message),
          ],
        ),
      ),
    );
  }
}

// --- payment

class PaymentPage extends StatefulWidget {
  final String sku;
  PaymentPage({this.sku});
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: WebView(
        initialUrl:
            'https://3b.my/stripe.php?pk=$stripe_publishable_key&sku=${widget.sku}',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (_) {
          print('created');
          _.getTitle().then((x) {
            print(x);
          });
        },
        onPageStarted: (_) {
          print('started');
          print(_);
        },
        onPageFinished: (_) {
          print('finished');
          print(_);
          final uri = Uri.dataFromString(_);
          if (uri.queryParameters['success'] == '1') {
            Navigator.of(context).pop(uri.queryParameters['session_id']);
          } else if (uri.queryParameters['cancel'] == '1') {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
