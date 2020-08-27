import 'package:flutter/material.dart';
import 'package:huawei_site_kit_web_api_demo/constants.dart';
import 'dart:convert';

import 'package:huawei_site_kit_web_api_demo/models/site.dart';
import 'package:huawei_site_kit_web_api_demo/models/coordinate.dart';
import 'models/nearby_place_search_request.dart';
import 'package:huawei_site_kit_web_api_demo/models/nearby_place_search_response.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  double _radius = 1000.0;
  NearbyPlaceResponse response;
  List<String> lst = ["Hotel", "Restaurant", "Hospital"];
  List<String> hwPoiTypes = ["HOTEL", "RESTAURANT", "GENERAL_HOSPITAL"];
  List<String> images = ['pizza-96.png','hamburger-96.png','noodles-96.png'];
  List<Site> sites = [];

  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Place Search Demo',style: TextStyle(color: primaryColor)),
          backgroundColor: ternaryColor,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 10.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomRadio(lst[0], 0),
                  CustomRadio(lst[1], 1),
                  CustomRadio(lst[2], 2)
                ]),
            SizedBox(height: 10.0),
            Container(
              height: 30,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 30),
                Expanded(
                  child: TextField(
                    controller: _latController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Latitude',
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Longitude',
                    ),
                  ),
                ),
                SizedBox(width: 30)
              ]),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Radius', style: TextStyle(color: ternaryColor, fontWeight: FontWeight.bold)),
              Slider(
                activeColor: secondaryColor,
                inactiveColor: ternaryColor,
                value: _radius,
                min: 100,
                max: 50000,
                divisions: 1000,
                label: _radius.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _radius = value;
                  });
                },
              ),
            ]),
            SizedBox(
              height: 1.0,
            ),
            Align(
              child: RaisedButton(
                onPressed: SendSearchRequest,
                child: Text('Search'),
                color: secondaryColor,
                textColor: primaryColor,
              ),
            ),
            SizedBox(height: 2.0),
            Divider(),
            Expanded(
              child: sites.length==0?Text('No results'):ListView.builder(
                itemCount: sites.length,
                itemBuilder: (context, index) {
                  return CustomCard(sites[index].name, sites[index].poi.phone,
                      sites[index].formatAddress, index);
                },
              ),
            )
          ]),
        ),
      ),
    );
  }

  void SendSearchRequest() async {
    NearbyPlaceRequest request = NearbyPlaceRequest(
        Coordinate(double.parse(_latController.text),
            double.parse(_lngController.text)),
        radius: _radius.toInt(),
        hwPoiType: hwPoiTypes[_selectedIndex]);

    String url =
        'https://siteapi.cloud.huawei.com/mapApi/v1/siteService/nearbySearch?key=';
    print(json.encode(request.toJson()));
    var res = await http.post(url + API_KEY,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(request.toJson()));
    response = NearbyPlaceResponse.fromJson(json.decode(utf8.decode(res.bodyBytes)));
    setState(() {
      sites = response.sites;
      sites.sort((a, b) => a.distance.compareTo(b.distance));
    });
  }

  void ChangeIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget CustomRadio(String text, int index) {
    bool isSelected = _selectedIndex == index;
    return RaisedButton(
      onPressed: () => ChangeIndex(index),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Text(text),
      textColor: isSelected ? primaryColor : ternaryColor,
      color: isSelected ? accentColor : primaryColor,
    );
  }

  Widget CustomCard(String name, String phoneNumber, String address, int index) {

    return Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Image.asset('assets/images/${images[index%3]}', width: 72),
              Text(name==null?'Name is Missing.':name, style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              SizedBox(height: 5.0),
              Text(phoneNumber==null?'Phone number is missing.':phoneNumber, style: TextStyle(color: Colors.grey, fontSize:12)),
              SizedBox(height: 10.0),
              Text(address==null?'Address is missing.':address, style: TextStyle(fontStyle: FontStyle.italic,), textAlign: TextAlign.center,),
            ],
          ),
        ));
  }
}
