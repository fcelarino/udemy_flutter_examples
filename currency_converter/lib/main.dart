import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus.unfocus(),
        child: MaterialApp(home: HomeView(title: 'Conversor Moedas'), theme: ThemeData(primarySwatch: Colors.yellow)));
  }
}

class HomeView extends StatefulWidget {
  HomeView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _dolarTextController = new TextEditingController();
  TextEditingController _euroTextController = new TextEditingController();
  TextEditingController _realTextController = new TextEditingController();

  Map _currencyInfo = new Map();

  @override
  void initState() {
    // call super
    super.initState();

    // load data
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrencyData());
  }

  void _loadCurrencyData() async {
    // call request
    http.Response response =
        await http.get(new Uri.https("api.hgbrasil.com", "finance", {"format": "json", "key": "72931dd1"}));

    // store data
    _currencyInfo = json.decode(response.body);

    // set initial data
    setState(() {
      _dolarTextController.text = _currencyInfo["results"]["currencies"]["USD"]["buy"].toString();
      _realTextController.text = 1.toStringAsFixed(2);
      _euroTextController.text = _currencyInfo["results"]["currencies"]["EUR"]["buy"].toString();
    });
  }

  Widget _createTextFormField(String label, TextEditingController textEditingController) {
    return Padding(
        padding: EdgeInsets.all(15),
        child: TextFormField(
          controller: textEditingController,
          validator: _validateCurrency,
          onChanged: _currencyChanged,
          style: TextStyle(color: Colors.yellow, fontSize: 25),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
              labelText: label,
              labelStyle: TextStyle(color: Colors.yellow, fontSize: 20)),
        ));
  }

  String _validateCurrency(String value) {
    if (value == null || value.isEmpty || double.parse(value) <= 0) {
      return "O valor precisa ser maior que 0";
    } else {
      return null;
    }
  }

  void _currencyChanged(String value) {
    // get currencies
    double dolarForSale = _currencyInfo["results"]["currencies"]["USD"]["buy"];
    double euroForSale = _currencyInfo["results"]["currencies"]["EUR"]["buy"];

    // get current data
    double dolar = double.tryParse(_dolarTextController.text) ?? 0;
    double euro = double.tryParse(_euroTextController.text) ?? 0;
    double real = double.tryParse(_realTextController.text) ?? 0;

    // check if dolar has changed
    if (_dolarTextController.text == value) {
      real = dolar * dolarForSale;
      euro = real / euroForSale;
    }

    // check if real has to be changed changed
    if (_realTextController.text == value) {
      dolar = real * dolarForSale;
      euro = real * euroForSale;
    }

    // check if euro has changed
    if (_euroTextController.text == value) {
      real = euro * euroForSale;
      dolar = real / dolarForSale;
    }

    // changing content
    setState(() {
      _dolarTextController.text = dolar.toStringAsFixed(2);
      _euroTextController.text = euro.toStringAsFixed(2);
      _realTextController.text = real.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Container(
            decoration: BoxDecoration(color: Colors.black),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.monetization_on, size: 120.0, color: Colors.yellow),
                    _createTextFormField("Real", _realTextController),
                    _createTextFormField("Dólar", _dolarTextController),
                    _createTextFormField("Euro", _euroTextController)
                  ],
                ))));
  }
}
