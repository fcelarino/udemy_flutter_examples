import 'package:flutter/material.dart';

void main() {
  runApp(IMCCalculatorApp());
}

class IMCCalculatorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus.unfocus(),
        child: MaterialApp(
          theme: ThemeData(primarySwatch: Colors.green),
          home: IMCHomeView(title: 'IMC Calculator'),
        ));
  }
}

class IMCHomeView extends StatefulWidget {
  IMCHomeView({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _IMCHomeViewState createState() => _IMCHomeViewState();
}

class _IMCHomeViewState extends State<IMCHomeView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _heightTextController = new TextEditingController();
  TextEditingController _weightTextController = new TextEditingController();

  String _imcEvaluation = "";

  String _validateValue(String value) {
    if (value == null || value.isEmpty || double.parse(value) <= 0) {
      return "O valor precisa ser maior que 0";
    } else {
      return null;
    }
  }

  void _resetCalculation() {
    setState(() {
      // dismiss keyboard
      FocusManager.instance.primaryFocus.unfocus();

      // reset fieldds
      _weightTextController.text = "";
      _heightTextController.text = "";
      _imcEvaluation = "";
    });
  }

  void _calculateImc() {
    // dismiss keyboard
    FocusManager.instance.primaryFocus.unfocus();

    // check if form is valid
    if (_formKey.currentState.validate()) {
      setState(() {
        // calculate imc
        double weight = double.parse(_weightTextController.text);
        double height = double.parse(_heightTextController.text) / 100;
        double imc = weight / (height * height);

        // decide message to be displayed
        if (imc < 18.6) {
          _imcEvaluation = "Abaixo do Peso (${imc.toStringAsPrecision(4)})";
        } else if (imc >= 18.6 && imc < 24.9) {
          _imcEvaluation = "Peso Ideal (${imc.toStringAsPrecision(4)})";
        } else if (imc >= 24.9 && imc < 29.9) {
          _imcEvaluation = "Levemente Acima do Peso (${imc.toStringAsPrecision(4)})";
        } else if (imc >= 29.9 && imc < 34.9) {
          _imcEvaluation = "Obesidade Grau I (${imc.toStringAsPrecision(4)})";
        } else if (imc >= 34.9 && imc < 39.9) {
          _imcEvaluation = "Obesidade Grau II (${imc.toStringAsPrecision(4)})";
        } else if (imc >= 40) {
          _imcEvaluation = "Obesidade Grau III (${imc.toStringAsPrecision(4)})";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _resetCalculation)],
        ),
        body: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              Icon(Icons.medical_services_rounded, size: 120.0, color: Colors.green),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      validator: _validateValue,
                      controller: _weightTextController,
                      onChanged: (value) => _formKey.currentState.validate(),
                      decoration: InputDecoration(
                          labelText: "Peso (kg)", labelStyle: TextStyle(fontSize: 20)))),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      validator: _validateValue,
                      controller: _heightTextController,
                      onChanged: (value) => _formKey.currentState.validate(),
                      decoration: InputDecoration(
                          labelText: "Altura (cm)", labelStyle: TextStyle(fontSize: 20)))),
              Padding(
                  padding: EdgeInsets.only(top: 35, left: 15, right: 15),
                  child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          child: Text("Calcular",
                              style: TextStyle(color: Colors.white, fontSize: 30.0)),
                          onPressed: _calculateImc))),
              Padding(
                  padding: EdgeInsets.all(15),
                  child: Visibility(visible: _imcEvaluation != "", child: Text(_imcEvaluation))),
            ])));
  }
}
