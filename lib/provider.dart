import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:location/location.dart';
import 'package:cron/cron.dart';

class User with ChangeNotifier{
  String _user_id='';
  String _password='';
  String _login_error='';
  String _machine='';
  String _car_number='';
  bool _local_storage=false;

  String _longitude='';
  String _latitude='';
  Location _location=Location();
  final _cron = Cron();



  String get user_id=> _user_id;
  String get password=> _password;
  String get login_error=> _login_error;
  bool get local_storage=>_local_storage;
  String get machine=> _machine;
  String get car_number=> _car_number;
  String get longitude=>_longitude;
  String get latitude=>_latitude;

  void setLocation() async
  {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await _location.getLocation();
    _longitude=_locationData.longitude.toString();
    _latitude=_locationData.latitude.toString();
  }
  void start_Cron (String Token) async
  {
    print("start_cron");
    _location.enableBackgroundMode(enable: true);


    _cron.schedule(Schedule.parse('* * * * *'), () async {
      try {
          setLocation();
          // final response=await http.post(Uri.parse(
          //     'https://auton-iot.com/api/gps/'),
          //     body: jsonEncode(
          //         <String, String>{"gps" : "SRID=4326;POINT ("+_longitude+' '+_latitude+')'}),
          //     headers: {'Content-Type': 'application/json',
          //       'Authorization': 'Token ' + Token});

          // Use current location
        }
      catch (e, s) {
        print(s);
      }
      });
  }

  void set_carnumber(String Token,String car_number) async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    final response=await http.patch(Uri.parse(
        'https://auton-iot.com/api/machine/'+_machine+'/'),
        body: jsonEncode(
            <String, String>{"car_number" : car_number}),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Token ' + Token});
    print("set_car_number" + response.body);
    if (response.statusCode==200)
    {
      prefs.setString('car_number', car_number);
      _car_number=car_number;
      _login_error="success";
    }
    else{_machine=''; _login_error = "차량 등록 과정에서 오류가 발생했습니다.";}
  }
  void set_login_error(String error){
    _login_error=error;
  }
  void check_saved_machine() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('machine')!=null)
      {
        _machine=prefs.getString('machine')!;
      }
    else{
      _machine='';
    }
    print("check_saved_machine" + _machine);
  }
  void set_machine(String qr, String Token) async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    final response=await http.patch(Uri.parse(
        'https://auton-iot.com/api/machine/'+qr+'/'),
        body: jsonEncode(
            <String, String>{"id": qr, "user": _user_id}),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Token ' + Token});
    print("set_machine" + response.body);
    if (response.statusCode==200)
    {
      _machine=qr;
      prefs.setString('machine', qr);
      _login_error="success";
    }
    else{_machine=''; _login_error = "차량 등록 과정에서 오류가 발생했습니다.";}

  }
  void insert_user_id_password (String user_id,String password,bool permanently_remember) async{

    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    _user_id=user_id;
    _password=password;

    if (permanently_remember)
    {
      try {
        prefs.setString('user_id', _user_id);
        prefs.setString('password', _password);
        print("아이디, 비번 모두 잘 입력됨");
        print(prefs.getString('user_id'));
        _login_error="success";

      }
      catch(e) {
        print("아이디/비번에 오류 생김");
        _login_error = '아이디/패스워드 저장 단계에서 오류가 발생했습니다.';
      }
    }
    notifyListeners();
  }
  void check_local_storage() async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    if (prefs.getString('user_id')==null || prefs.getString('password')==null)
      {
        _login_error=("로컬에 데이터가 없음");
        prefs.clear();
        _local_storage=false;
      }
    else
      {
        _user_id=prefs.getString('user_id')!;
        _password=prefs.getString('password')!;
        if (prefs.getString('car_number') != null)
          {
            _car_number=prefs.getString('car_number')!;
          }
        _local_storage=true;
        _login_error="success";
      }

  }

  void delete_user_id_password_from_localstorage(String Token) async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    try{
      prefs.clear();
      //로그아웃시 서버에서 user와 machine의 connect도 끊어준다.
      if (_machine!='') {
        final response = await http.patch(Uri.parse(
            'https://auton-iot.com/api/machine/' + _machine + '/'),
            body: jsonEncode(
                <String, String>{"user": ""}),
            headers: {'Content-Type': 'application/json',
              'Accept': 'application/json','Authorization': 'Token ' + Token});
        Timer(Duration(milliseconds: 200), () {
          print("delete user " + response.statusCode.toString());
        });
      }


    }
    catch (e)
    {
      _login_error='로그인 정보 삭제 과정에서 오류가 발생했습니다.';
      notifyListeners();
    }
    _machine='';
    _user_id='';
    _password='';
    _car_number='';
    _login_error="success";
  }
  void delete_machine_from_localstorage(String Token) async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    try{
      //로그아웃시 서버에서 user와 machine의 connect도 끊어준다.
      if (_machine!='')
      {
        final response=await http.patch(Uri.parse(
            'https://auton-iot.com/api/machine/' + _machine + '/'),
            body: jsonEncode(
                <String, String>{"user": ""}),
            headers: {'Content-Type': 'application/json',
              'Accept': 'application/json', 'Authorization': 'Token ' + Token});
        Timer(Duration(milliseconds: 200), () {
          print("delete user " + response.body);
        });
        if(response.statusCode !=200) {
          _login_error = "delete 과정에서 오류가 발생했습니다.";
        }

      }


    }
    catch (e)
    {
      _login_error='로그인 정보 삭제 과정에서 오류가 발생했습니다.';
      notifyListeners();
    }
    prefs.setString('machine','');//그런 다음 로칼의 machine 데이터를 없앤다.
    prefs.setString('car_number','');
    _machine='';
    _car_number='';
    _login_error="success";
  }

}
class Token_login with ChangeNotifier {
  String _Token = '';

  String get Token => _Token;

  String _login = '';

  String get login => _login;

  void signup_api_server(String username,String password1, String password2) async {
    final response=await http.post(Uri.parse(
        'https://auton-iot.com/rest-auth/registration/'),
      body: jsonEncode(
          <String, String>{"username": username, "password1": password1, "password2" : password2}),
    headers: {'Content-Type': 'application/json',
        'Accept': 'application/json'});
    if (response.statusCode==201)
      {
        Map<String,dynamic> data = jsonDecode(response.body);
        _Token = data['key'];
        _login='success';
      }
    else{_login=response.body;}
    notifyListeners();
  }

  void login_api_server(String username, String password) async {
    final response = await http.post(Uri.parse(
        'https://auton-iot.com/api-token-auth/'),
      body: jsonEncode(
          <String, String>{"username": username, "password": password}),headers: {'Content-Type': 'application/json',
          'Accept': 'application/json'});
    if (response.statusCode == 200) {
      Map<String,dynamic> data = jsonDecode(response.body);
      _Token = data['token'];
      _login = 'success';
    }
    else {
      _login = response.body;
    }
    notifyListeners();
  }
  void logout_api_server() async{
    _login='';
    _Token='';
  }
}
