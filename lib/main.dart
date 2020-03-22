import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "dart:async";
import 'dart:convert' as convert;

const request = "https://api.hgbrasil.com/finance?key=c035fae8";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  var response = await http.get(request);
  return convert.jsonDecode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final usdController = TextEditingController();
  final eurController = TextEditingController();

  double usd;
  double eur;

  void _clearAll(){
    realController.text = "";
    usdController.text = "";
    eurController.text = "";
  }

  void _realChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    usdController.text = (real / usd).toStringAsFixed(2);
    eurController.text = (real / eur).toStringAsFixed(2);
  }

  void _usdChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double usd = double.parse(text);
    realController.text = (usd * this.usd).toStringAsFixed(2);
    eurController.text = (usd * this.usd / eur).toStringAsFixed(2);
  }

  void _eurChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double eur = double.parse(text);
    realController.text = (eur * this.eur).toStringAsFixed(2);
    usdController.text = (eur * this.eur / usd).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _clearAll,)
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Não foi possível buscar os dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  ),
                );
              } else {
                usd = snapshot.data["results"]["currencies"]["USD"]["buy"];
                eur = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "\$", usdController, _usdChanged),
                      Divider(),
                      buildTextField("Euros", "€", eurController, _eurChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function changedFunctions) {
  return TextField(
    controller: controller,
    onChanged: changedFunctions,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, ),
  );
}
