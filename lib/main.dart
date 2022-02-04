import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'API.dart';
import 'pannels.dart';
import 'provider.dart';
import 'dart:io';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'ranker.dart';
import 'package:cron/cron.dart';
import 'package:location/location.dart';


void main() {

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => User()),
      ChangeNotifierProvider(create: (_) => Token_login()),
    ],
    child : MaterialApp(
      title:"auton",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansKR',
        primaryColor: Colors.lightGreen,
      ),

      routes:
      {
        '/splash': (context) => SplashScreen(),
        '/login' : (context) => Login_View(),
        '/qr' : (context) => QR_View(),
        '/' : (context) => MyHomePage(title: '박경만'),
      },
      initialRoute:'/splash',
      // home: MyHomePage(title:'박경만'),
    ),
  )
  );
}
class Login_View extends StatefulWidget{
  const Login_View({Key? key}) : super(key : key);
  @override
  State<Login_View> createState()=>_Login_View_State();
}
class _Login_View_State extends State<Login_View>
{

  Duration get loginTime => Duration(milliseconds: 5000);
  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    context.read<Token_login>().login_api_server(data.name,data.password);

    return Future.delayed(loginTime).then((_) {
      if (context.read<Token_login>().login!='success') {
        return context.read<Token_login>().login;
      }
      else{
        context.read<User>().insert_user_id_password(data.name,data.password,true);
        return null;
      }

    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    context.read<Token_login>().signup_api_server(data.name!,data.password!,data.password!);

    return Future.delayed(loginTime).then((_) {
      if (context.read<Token_login>().login!='success') {
        return context.read<Token_login>().login;
      }
      else{
        context.read<User>().insert_user_id_password(data.name!,data.password!,true);

        return null;
      }
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');

    return Future.delayed(loginTime).then((_) {

      return '지원하지 않는 기능입니다.';
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope (

        onWillPop: ()=>exit(0),
        child :FlutterLogin(


          theme: LoginTheme(
            primaryColor: Color(0xfffbfff9),
            accentColor: Colors.white,
            errorColor: Colors.deepOrange,
            titleStyle: TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'NotoSansKR',
              letterSpacing: 4,
            ),
            switchAuthTextColor : Colors.green,
            buttonTheme: LoginButtonTheme(
              splashColor: Colors.white,
              backgroundColor: Colors.green,
              highlightColor: Colors.lightGreen,
              elevation: 9.0,
              highlightElevation: 6.0,
            ),
          ),
          userType :LoginUserType.name,
          userValidator: (String? name)=>null,
          logo: AssetImage('images/logo.png'),
          onLogin: _authUser,
          onSignup: _signupUser,
          onSubmitAnimationCompleted: () {
            if(context.read<User>().login_error!='success') {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: new Text("로그인, 회원가입 과정에서 문제가 생김"),
                      content: new Text(context
                          .read<User>()
                          .login_error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      actions: <Widget>[

                        new TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: new Text("확인"),
                        ),
                      ],
                    );
                  }
              );
              Navigator.pushNamed(context,'/login');
            }
            if (context
                .read<User>()
                .machine == '') {
              Navigator.pushNamed(context,'/qr');
            }
            else {
              Navigator.pushNamed(context, '/');
            }
          },
          onRecoverPassword: _recoverPassword,
          hideForgotPasswordButton : true,
          messages: LoginMessages(
            userHint: '아이디',
            passwordHint: '비밀번호',
            confirmPasswordHint: '비밀번호를 한번 더 입력해주세요',
            loginButton: '로그인',
            signupButton: '회원 가입',
            confirmPasswordError: '비밀번호가 동일하지 않습니다.',
          ),
        )
    );
  }
}

class QR_View extends StatefulWidget{
  const QR_View({Key? key}) : super(key : key);
  @override
  State<QR_View> createState()=>_QR_View_State();
}
class _QR_View_State extends State<QR_View>
{
  String result = "카메라 버튼을 눌러 qr 코드를 스캔하세요 .";

  Future _scanQR() async {
    //var qrResult = await BarcodeScanner.scan();

    //context.read<User>().set_machine(qrResult.rawContent.toString(),context.read<Token_login>().Token);
    context.read<User>().set_machine("41",context.read<Token_login>().Token);
    Timer(Duration(milliseconds: 700), () {
      context
          .read<User>()
          .login_error == "success" ? Navigator.pushNamed(context, '/') :
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("경고"),
            content: new Text(context
                .read<User>()
                .login_error),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
            ),
            actions: <Widget>[

              new TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text("확인"),
              ),
            ],
          );
        },
      );
    });
    setState(() {
      //result = qrResult.rawContent.toString();
    });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()=>exit(0),
        child : Scaffold(
          backgroundColor: Color(0xfffbfff9),
          appBar: AppBar(
            title: Text("QR Scanner",style : TextStyle(fontFamily: 'NotoSansKR',)),
            backgroundColor : Colors.green,
            actions: [
              IconButton(
                  icon : Icon(IconData(0xe3b3, fontFamily: 'MaterialIcons')),
                  onPressed: (){
                    context.read<User>().delete_user_id_password_from_localstorage(context.read<Token_login>().Token);
                    context.read<Token_login>().logout_api_server();
                    Navigator.pushNamed(context,'/login');
                  }
              ),
            ],
          ),
          body: Center(
            child: Text(
              result,
              style: new TextStyle(fontFamily: 'NotoSansKR',fontSize: MediaQuery.of(context).size.width*0.05, color: Colors.green),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: Icon(Icons.camera_alt),
            label: Text("Scan",style : TextStyle(fontFamily: 'NotoSansKR',)),
            onPressed: _scanQR,
            // 이 아래의 onPressed 내용은 전부 임시이다. 싹다 지울것.
            // onPressed: (){
            // context.read<User>().set_machine("45",context.read<Token_login>().Token);
            // Timer(Duration(milliseconds: 300), () {
            // print(context.read<User>().login_error);
            // context.read<User>().login_error == "success" ? Navigator.pushNamed(context,'/') :
            //   showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return AlertDialog(
            //         title: new Text("경고"),
            //         content: new Text(context.read<User>().login_error),
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8.0)
            //         ),
            //         actions: <Widget>[
            //
            //           new TextButton(
            //             onPressed: () {
            //               Navigator.pop(context);
            //             },
            //             child: new Text("확인"),
            //           ),
            //         ],
            //       );
            //     },
            //   );
            // setState(() {result="41";});
            // });
            // },
            backgroundColor:Colors.green,
            focusColor:Colors.lightGreen,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        )
    );
  }
}
class SplashScreen extends StatefulWidget{
  const SplashScreen({Key? key}) : super(key : key);
  @override
  State<SplashScreen> createState()=>_SplashScreen_State();
}

class _SplashScreen_State extends State<SplashScreen>{
  @override
  void initState() {
    super.initState();
    bool local_storage = false;
    context.read<User>().check_local_storage(); // 계정 존재 여부 확인.



    Timer(Duration(milliseconds: 300), () {

      local_storage=context.read<User>().local_storage;


      if(local_storage){
        bool login_success=false;
        bool machine_exists=false;
        context.read<User>().check_saved_machine(); // machine이 해당 계정에 존재하는 지 확인.

        String username = context.read<User>().user_id;
        String password = context.read<User>().password;
        context.read<Token_login>().login_api_server(username,password); // 로그인을 해서 token도 저장한다(시간이 다소 소요)


        Timer(Duration(milliseconds: 1200), () {

          login_success=context.read<Token_login>().login=='success';
          machine_exists= (context.read<User>().machine!='');

          if (login_success) {
            if (machine_exists) {
              Navigator.pushNamed(context, '/');
            }
            else
            {
              Navigator.pushNamed(context,'/qr');
            }
          }
          else{
            context.read<User>().set_login_error('서버 점검 등의 문제로 로그인 실패했습니다. 재로그인 해주세요.');
            Navigator.pushNamed(context, '/login');
          }
        });


      }
      else
      {
        Navigator.pushNamed(context, '/login');
      }

    });

  }
  @override
  Widget build(BuildContext context)
  {

    return   WillPopScope(
      onWillPop: () async =>false,
      child:Scaffold(
        backgroundColor : Color(0xfffbfff9),
        body : Container(
          height : MediaQuery.of(context).size.height,
          width : MediaQuery.of(context).size.width,
          child : Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              SizedBox(height: MediaQuery.of(context).size.height*0.4),
              Image.asset('images/logo.png', width: 200, fit: BoxFit.cover),
              SizedBox(height: MediaQuery.of(context).size.height*0.1),
              Text("차량내 공기질 실시간 모니터링 어플리케이션",style: TextStyle(fontFamily: 'NotoSansKR',fontSize: MediaQuery.of(context).size.width*0.05,color: Colors.blueGrey)),
              Expanded(child: SizedBox()),
              Text("© Copyright 2022. (주) 오토앤, 서울대학교 산학협력단, 창의과학협회.", style: TextStyle(fontFamily:'NotoSansKR',fontSize: MediaQuery.of(context).size.width*0.03,color: Colors.green)),
              SizedBox(height: MediaQuery.of(context).size.height*0.05),
            ],
          ),
        ),
      ),
    );


  }
}
class CarNumberInputer extends StatelessWidget
{

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor:Color(0xfffbfff9),
        appBar: AppBar(
          title : Text("차량번호 입력",style : TextStyle(fontFamily: 'NotoSansKR',)),
          backgroundColor : Colors.green,
        ),
        body : Center(
            child : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height:MediaQuery.of(context).size.height*0.1),
                Icon(IconData(0xe1d7, fontFamily: 'MaterialIcons')),
                SizedBox(height:MediaQuery.of(context).size.height*0.1),
                Text("차량번호를 입력하시면 추후 다양한 연계 서비스를 지원받으실 수 있습니다.",style : TextStyle(fontFamily: 'NotoSansKR',),textAlign:TextAlign.center),
                Container(
                    margin: EdgeInsets.all(8),
                    child:TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: myController,
                      onSubmitted: (text){ Navigator.pop(context,text);},
                    )
                ),
                FloatingActionButton.extended(
                  icon:Icon(Icons.add),
                  label:Text("입력",style : TextStyle(fontFamily: 'NotoSansKR',)),
                  onPressed: () {
                    Navigator.pop(context,myController.text);
                  },
                ),
              ],
            )
        )
    );

  }
}

class MyHomePage extends StatefulWidget {

  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;

  @override
  void initState()
  {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () =>exit(0),
        child:Scaffold(
          //backgroundColor:Color.fromARGB(8,0,255,0),
          endDrawerEnableOpenDragGesture: false,

          endDrawer:
          Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:[
                Expanded(
                  child : ListView(
                    padding: EdgeInsets.all(32),
                    children: [
                      ListTile(
                        title: const Text('차량 번호 입력',style : TextStyle(fontFamily: 'NotoSansKR',)),
                        onTap: () async {
                          final result = await Navigator.push(context,MaterialPageRoute(builder: (context) => CarNumberInputer()));
                          print(result);
                          result != null ? context.read<User>().set_carnumber(context.read<Token_login>().Token,result) :
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: new Text("경고"),
                                  content: new Text("차량 번호를 입력하지 않으셨습니다."),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: new Text("확인"),
                                    ),

                                  ],
                                );
                              }

                          );



                          // Update the state of the app
                          // ...
                          // Then close   the drawer
                          //Navigator.pop(context);
                        },
                      ),


                      ListTile(
                          title: const Text('차량 로그아웃',style : TextStyle(fontFamily: 'NotoSansKR',)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: new Text("경고"),
                                  content: new Text("정말로 지금 등록된 차량의 정보를 기기에서 삭제하겠습니까?"),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  actions: <Widget>[
                                    new TextButton(
                                      onPressed: () {
                                        context.read<User>().delete_machine_from_localstorage(context.read<Token_login>().Token);
                                        context.read<Token_login>().logout_api_server();
                                        Navigator.pushNamed(context,'/splash');
                                      },
                                      child: new Text("로그아웃"),
                                    ),
                                    new TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: new Text("취소"),
                                    ),
                                  ],
                                );
                                // Update the state of the app
                                // ...
                                // Then close   the drawer
                                //Navigator.pop(context);
                              },
                            );
                          }
                      ),
                      ListTile(
                        title: const Text('개발팀 문의',style : TextStyle(fontFamily: 'NotoSansKR',)),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: new Text("개발팀 문의"),
                                content: new Text("Call : 010-7371-6929\nEmail : zzangman2@gmail.com"),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)
                                ),
                                actions: <Widget>[
                                  new TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: new Text("확인"),
                                  ),

                                ],
                              );
                              // Update the state of the app
                              // ...
                              // Then close   the drawer
                              //Navigator.pop(context);
                            },
                          );
                        },
                      ),

                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text("경고"),
                          content: new Text("정말로 지금 로그인된 정보를 기기에서 완전히 삭제하겠습니까?\n회원탈퇴는 개발자 문의를 이용해주세요."),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                          ),
                          actions: <Widget>[
                            new TextButton(
                              onPressed: () {
                                context.read<User>().delete_user_id_password_from_localstorage(context.read<Token_login>().Token);
                                context.read<Token_login>().logout_api_server();
                                Navigator.pushNamed(context,'/splash');
                              },
                              child: new Text("로그아웃",),
                            ),
                            new TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: new Text("취소"),
                            ),
                          ],
                        );
                        // Update the state of the app
                        // ...
                        // Then close   the drawer
                        //Navigator.pop(context);
                      },
                    );
                  },
                  child: Text("사용자 로그아웃",style : TextStyle(fontFamily: 'NotoSansKR', color : Colors.black)),
                )
              ],
            ),
          ),
          appBar: AppBar(

            backgroundColor: Color(0xff19B35D),
            elevation: 0,
            centerTitle: true,
            actions : [
              Builder(
                builder: (BuildContext context){
                  return IconButton(
                    tooltip: 'settings',
                    color: Colors.white,
                    icon: const Icon(
                      Icons.settings,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
            ],
            title: Image.asset('images/logowhite.png', width: 100, height: 40, fit: BoxFit.cover),
          ),
          body: VerticallyScrollablePage(page : _index+1),

          bottomNavigationBar : BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            selectedItemColor: Colors.yellow,
            unselectedItemColor: Colors.white,


            onTap:(index){
              setState((){
                _index=index;
              });
            },
            currentIndex : _index,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: '실시간',
                icon: Icon(Icons.update_rounded),
                backgroundColor:Color(0xff19B35D),

              ),
              BottomNavigationBarItem(
                label: '통계',
                icon: Icon(Icons.query_stats ),
                backgroundColor:Color(0xff19B35D),
              ),
              BottomNavigationBarItem(
                label: '분석',
                icon: Icon(Icons.smart_toy_outlined),
                backgroundColor:Color(0xff19B35D),
              ),
            ],
          ),
        )
    );
  }
}

class VerticallyScrollablePage extends StatelessWidget{
  final int page;
  const VerticallyScrollablePage({Key? key, required this.page}) : super(key:key);


  Widget build(BuildContext context) {
    final PageController controller = PageController();

    switch (page) {
      case 1 :
        return  PageView(controller: controller,
            children: <Widget>[
              Inside_outside(is_inside: true),
              Inside_outside(is_inside: false),
            ]
        );
      case 2 :
        return PageView(controller: controller,
          children: <Widget>[
            OneDay_SevenDay_ThirtyDay(one_seven_thirty : 0),
            OneDay_SevenDay_ThirtyDay(one_seven_thirty : 1),
            OneDay_SevenDay_ThirtyDay(one_seven_thirty : 2),
          ],
        );
      case 3 :
        return Page3();
      default :
        return Error_page();
    }
  }
}


class OneDay_SevenDay_ThirtyDay extends StatefulWidget{
  final int one_seven_thirty;

  const OneDay_SevenDay_ThirtyDay({Key? key, required this.one_seven_thirty}) : super(key: key);
  @override
  State<OneDay_SevenDay_ThirtyDay> createState() => _OneDay_SevenDay_ThirtyDay_State();
}
class _OneDay_SevenDay_ThirtyDay_State extends State<OneDay_SevenDay_ThirtyDay>{
  List<String> title=['시간대별 공기질 통계','일별 공기질 통계','주별 공기질 통계'];

  List<String> total_rate_list=['쾌적','주의','나쁨','매우 나쁨'];

  double total_1 = 0;
  double total_2 = 0;
  int _totalvalue=0;//API 데이터를 받아와, 2차가공을 하는 클래스가 필요함.
  String _total_rate='쾌적';
  String _name='P.M 2.5';
  bool isChecked_average=true;
  bool isChecked_worst=false;
  DateTime _select_day= DateTime.now();

  // List data_1=[{'hours' : 0, 'hours_worst' : 0, 'pub_date' : 0}];
  // List data_2=[{'hours' : 0, 'hours_worst' : 0, 'pub_date' : 0}];
  List? data_1;
  List? data_2;


  void call_sensor_hour() async
  {
    int null_number_1=0;
    int null_number_2=0;
    final response = await http.get(
        Uri.parse('https://auton-iot.com/api/hours_sensor/?pub_date__gte=' + _select_day.year.toString() +"-"+_select_day.month.toString()+"-" +_select_day.day.toString()+"&pub_date__lte=" +(_select_day.add(Duration(days:1)).year).toString() +"-"+(_select_day.add(Duration(days:1)).month).toString()+"-" +(_select_day.add(Duration(days:1)).day).toString()),
        headers: {'Authorization': 'Token ' + context
            .read<Token_login>()
            .Token});
    setState(()
    {
      data_1=jsonDecode(response.body);
      for (int i = 0; i < data_1!.length; i++) {

        data_1![i]['hours'] != null
            ? total_1 = data_1![i]['hours'].toDouble() + total_1
            : null_number_1++;

        data_1![i]['hours_worst'] != null
            ? total_2 = data_1![i]['hours_worst'].toDouble() + total_2
            : null_number_2++;

      }
      data_1!.length-null_number_1!=0 ? total_1=total_1/(data_1!.length-null_number_1) : total_1=0;
      data_1!.length-null_number_2!=0 ? total_2=total_2/(data_1!.length-null_number_2) : total_2=0;

      _totalvalue = total_1.toInt(); // init 에서는 average를 totalvalue로 친다.
      _total_rate = Ranker(total_1, _name);
    });
  }
  void call_airkorea_hour() async
  {
    final response = await http.get(
        Uri.parse('https://auton-iot.com/api/hours_airkorea/?pub_date__gte=' + _select_day.year.toString() +"-"+_select_day.month.toString()+"-" +_select_day.day.toString()+"&pub_date__lte=" +(_select_day.add(Duration(days:1)).year).toString() +"-"+(_select_day.add(Duration(days:1)).month).toString()+"-" +(_select_day.add(Duration(days:1)).day).toString()),
        headers: {'Authorization': 'Token ' + context
            .read<Token_login>()
            .Token});
    setState((){data_2=jsonDecode(response.body);});
  }
  void call_sensor_day() async
  {
    int null_number_1=0;
    int null_number_2=0;

    final response = await http.get(
        Uri.parse('https://auton-iot.com/api/days_sensor/?pub_date__gte=' + _select_day.subtract(Duration(days:7)).year.toString() +"-"+_select_day.subtract(Duration(days:7)).month.toString()+"-" +_select_day.subtract(Duration(days:7)).day.toString()+"&pub_date__lte=" +(_select_day.add(Duration(days:1)).year).toString() +"-"+(_select_day.add(Duration(days:1)).month).toString()+"-" +(_select_day.add(Duration(days:1)).day).toString()),
        headers: {'Authorization': 'Token ' + context
            .read<Token_login>()
            .Token});
    setState(()
    {
      data_1=jsonDecode(response.body);
      for (int i = 0; i < data_1!.length; i++) {

        data_1![i]['days'] != null
            ? total_1 = data_1![i]['days'].toDouble() + total_1
            : null_number_1++;

        data_1![i]['days_worst'] != null
            ? total_2 = data_1![i]['days_worst'].toDouble() + total_2
            : null_number_2++;

      }
      data_1!.length-null_number_1!=0 ? total_1=total_1/(data_1!.length-null_number_1) : total_1=0;
      data_1!.length-null_number_2!=0 ? total_2=total_2/(data_1!.length-null_number_2) : total_2=0;

      _totalvalue = total_1.toInt(); // init 에서는 average를 totalvalue로 친다.
      _total_rate = Ranker(total_1, _name);
    });
  }
  void call_airkorea_day() async
  {
    final response = await http.get(
        Uri.parse('https://auton-iot.com/api/days_airkorea/?pub_date__gte=' + _select_day.subtract(Duration(days:7)).year.toString() +"-"+_select_day.subtract(Duration(days:7)).month.toString()+"-" +_select_day.subtract(Duration(days:7)).day.toString()+"&pub_date__lte=" +(_select_day.add(Duration(days:1)).year).toString() +"-"+(_select_day.add(Duration(days:1)).month).toString()+"-" +(_select_day.add(Duration(days:1)).day).toString()),
        headers: {'Authorization': 'Token ' + context
            .read<Token_login>()
            .Token});
    setState((){data_2=jsonDecode(response.body);});
  }
  void call_sensor_week() async
  {
    int null_number_1=0;
    int null_number_2=0;
    final response = await http.get(
        Uri.parse('https://auton-iot.com/api/weeks_sensor/?pub_date__gte=' + _select_day.subtract(Duration(days:70)).year.toString() +"-"+_select_day.subtract(Duration(days:70)).month.toString()+"-" +_select_day.subtract(Duration(days:70)).day.toString()+"&pub_date__lte=" +(_select_day.add(Duration(days:70)).year).toString() +"-"+(_select_day.add(Duration(days:1)).month).toString()+"-" +(_select_day.add(Duration(days:1)).day).toString()),
        headers: {'Authorization': 'Token ' + context
            .read<Token_login>()
            .Token});
    setState(()
    {
      data_1=jsonDecode(response.body);
      for (int i = 0; i < data_1!.length; i++) {

        data_1![i]['weeks'] != null
            ? total_1 = data_1![i]['weeks'].toDouble() + total_1
            : null_number_1++;

        data_1![i]['weeks_worst'] != null
            ? total_2 = data_1![i]['weeks_worst'].toDouble() + total_2
            : null_number_2++;

      }
      data_1!.length-null_number_1!=0 ? total_1=total_1/(data_1!.length-null_number_1) : total_1=0;
      data_1!.length-null_number_2!=0 ? total_2=total_2/(data_1!.length-null_number_2) : total_2=0;

      _totalvalue = total_1.toInt(); // init 에서는 average를 totalvalue로 친다.
      _total_rate = Ranker(total_1, _name);
    });
  }
  void call_airkorea_week() async
  {
    final response = await http.get(
        Uri.parse('https://auton-iot.com/api/weeks_airkorea/?pub_date__gte=' + _select_day.subtract(Duration(days:70)).year.toString() +"-"+_select_day.subtract(Duration(days:70)).month.toString()+"-" +_select_day.subtract(Duration(days:70)).day.toString()+"&pub_date__lte=" +(_select_day.add(Duration(days:70)).year).toString() +"-"+(_select_day.add(Duration(days:1)).month).toString()+"-" +(_select_day.add(Duration(days:1)).day).toString()),
        headers: {'Authorization': 'Token ' + context
            .read<Token_login>()
            .Token});

    setState((){data_2=jsonDecode(response.body);});
  }
  void _date_selector(DateTime date)
  {
    setState((){_select_day=date;
    switch(widget.one_seven_thirty)
    {
      case 0:
        {

          call_sensor_hour();
          call_airkorea_hour();

          break;
        }
      case 1:
        {
          call_sensor_day();
          call_airkorea_day();
          break;
        }

      case 2:
        {
          call_sensor_week();
          call_airkorea_week();
          break;
        }
      default :
        break;
    }
    });
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    switch(widget.one_seven_thirty)
    {
      case 0:
        {

          call_sensor_hour();
          call_airkorea_hour();

          break;
        }
      case 1:
        {
          call_sensor_day();
          call_airkorea_day();
          break;
        }

      case 2:
        {
          call_sensor_week();
          call_airkorea_week();
          break;
        }
      default :
        break;
    }

  }
  Future<void> _refresh() async
  {
    switch(widget.one_seven_thirty)
    {
      case 0:
        {

          call_sensor_hour();
          call_airkorea_hour();

          break;
        }
      case 1:
        {
          call_sensor_day();
          call_airkorea_day();
          break;
        }

      case 2:
        {
          call_sensor_week();
          call_airkorea_week();
          break;
        }
      default :
        break;
    }
  }

  @override
  Widget build(BuildContext context){

    return(RefreshIndicator(
      onRefresh: _refresh,

      child : ListView(
        children : [Container(

            color:Color(0xff19B35D),

            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(children:[Left_right_scroll(left_right_scroll_text : title[widget.one_seven_thirty]),
                  Date_DateRange_Picker(page : widget.one_seven_thirty, setdate: _date_selector,),]),

                Container(
                  margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015), MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015),),
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height*(0.025)),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white,
                    // boxShadow: [
                    //   BoxShadow(
                    //     spreadRadius: 2,
                    //     color: Colors.grey,
                    //     offset: Offset(2, 3),
                    //     blurRadius: 1.5,
                    //   )
                    // ],
                  ),

                  child :(
                      SizedBox(
                        width:MediaQuery.of(context).size.width,
                        height:MediaQuery.of(context).size.height*(0.3),
                        child:Total_pannel(scale : 1.2, totalvalue : _totalvalue.toDouble(), total_rate : _total_rate, name_of_evaluate : (_name),unit :(_name=='khai' ? '통합공기지수':'㎍/㎥' ), text_size: 12,width:200,total_rate_size:15 ),
                      )
                  ),
                ),

                Container(
                  height: MediaQuery.of(context).size.height*(0.35),
                  margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015), MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015),),
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height*(0.02)),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white,
                    // boxShadow: [
                    // BoxShadow(
                    // spreadRadius: 2,
                    // color: Colors.grey,
                    // offset: Offset(2, 3),
                    // blurRadius: 1.5,
                    // )
                    // ],
                  ),
                  child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      children : [
                        Row(
                          mainAxisAlignment:MainAxisAlignment.end,
                          children :[
                            SizedBox(width:10,height:10,child : const DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Colors.lightGreen
                              ),),),
                            Text(" : 차량 내 공기   ",style:TextStyle(fontFamily: 'NotoSansKR',fontSize:10)),
                            SizedBox(width:10,height:10,child : const DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Colors.grey
                              ),),),
                            SizedBox.square(child:Container(color:Colors.grey)),
                            Text(" : 실외 공기",style:TextStyle(fontFamily: 'NotoSansKR',fontSize:10)),
                          ],
                        ),
                        Expanded(child:(data_1==null || data_2==null) ? CircularProgressIndicator() : GroupedBarChart.withSampleData(data_1!,data_2!,isChecked_average,widget.one_seven_thirty),
                        ),
                      ]
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      splashRadius: 3,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      activeColor: Colors.transparent,
                      checkColor: Colors.yellow,
                      value: isChecked_average,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked_average = value!;
                          isChecked_worst=!value;
                          _totalvalue=total_1.toInt();
                        });
                      },
                    ),


                    Text('평균',style : TextStyle(fontFamily: 'NotoSansKR',color: isChecked_average? Colors.yellow : Colors.white,),),
                    Checkbox(

                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      activeColor: Colors.transparent,
                      checkColor: Colors.yellow,
                      splashRadius: 3,
                      value: isChecked_worst,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked_worst = value!;
                          isChecked_average=!value;

                          _totalvalue=total_2.toInt();
                        });
                      },
                    ),
                    Text('가장 나쁨',style : TextStyle(fontFamily: 'NotoSansKR',color: isChecked_worst? Colors.yellow : Colors.white,),),
                  ],
                ),

              ],
            )
        )
        ],
      ),
    )
    );
  }
}



class Inside_outside extends StatefulWidget{
  final bool is_inside;
  const Inside_outside({Key? key, required this.is_inside}) : super(key: key);
  @override
  State<Inside_outside> createState() => _Inside_outside_State();
}
class _Inside_outside_State extends State<Inside_outside> {
  String left_right_scroll_text = '실내공기'; // state 아님.
  List<String> name_lists = ["temperature", "humidity", "CO2", "P.M 2.5"];
  List<String> unit_lists = ["℃", "％", "ppm", "㎍/㎥"];


  Map<String, dynamic> data={"sensor":{"P.M 2.5" : 0}}; // state. api 호출하는 부분에서 setState. inside면 airkorea, outside면 airkorea.
  int _totalvalue = 0; //total_rate와 같음.
  String _total_rate = "쾌적"; //state. api 호출하는 부분의 setState에서 calculateTotalValue 호출.
  String _location = ""; //state.
  String _datetime='';

  @override
  void initState() {
    //print(widget.is_inside.toString());
    super.initState();
    context.read<User>().start_Cron(context.read<Token_login>().Token);
    context.read<User>().setLocation();//Cronjob으로 등록한 작업은 다소 시간이 흐른 다음에 되므로 맨 처음에 한번 불러줘야지
    //최초에 위치가 잘 설정된다.
    left_right_scroll_text = widget.is_inside ? "실내 공기" : "실시간 대기질";
    name_lists = widget.is_inside ? ["temperature", "humidity", "CO2", "P.M 2.5"] : [
      "CO",
      "O3",
      "SO2",
      "NO2",
      "P.M 2.5"
    ];
    unit_lists = widget.is_inside ? ["℃", "％", "ppm", "㎍/㎥"] : [
      "ppm",
      "ppm",
      "ppm",
      "ppm",
      "㎍/㎥"
    ];

  }

  void call_api() async {
    if (widget.is_inside) {

      data={"sensor":{"P.M 2.5" : 0, "temperature" : 0, "humidity" : 0, "CO2" : 0}};
      //더미 기본값(없으면 렌더링 극초반에 null error가 뜸.)
      final response = await http.get(
          Uri.parse('https://auton-iot.com/api/sensor/'), headers: {'Authorization': 'Token ' + context
          .read<Token_login>()
          .Token});
      // http call.


      if (response.statusCode == 200) {

        setState(() {
          data = jsonDecode(response.body);
          _datetime=data['pub_date'].toString().split('T')[0].split('-')[1] +'월 '+data['pub_date'].toString().split('T')[0].split('-')[2]+'일  ' + data['pub_date'].toString().split('T')[1].split('.')[0].split(':')[0]+'시 '+data['pub_date'].toString().split('T')[1].split('.')[0].split(':')[1]+'분';
          _totalvalue = data['sensor']['P.M 2.5'];
          _total_rate=Ranker(_totalvalue.toDouble(),'P.M 2.5');
        });
      }
    }

    else { // airkorea.
      data={"sensor":{"P.M 2.5" : 0, "CO" : 0, "SO2" : 0, "NO2" : 0,"O3" : 0,"khai":0}};
      //더미 기본값(없으면 렌더링 극초반에 null error가 뜸.)

      final response = await http.get(
          Uri.parse('https://auton-iot.com/api/airkorea/' + '?machine=' + context
              .read<User>()
              .machine), headers: {'Authorization': 'Token ' + context
          .read<Token_login>()
          .Token});
      // http call.

      if (response.statusCode == 200 ) {

        setState(() {
          data = jsonDecode(response.body);
          _datetime=data['pub_date'].toString().split('T')[0].split('-')[1] +'월 '+data['pub_date'].toString().split('T')[0].split('-')[2]+'일  ' + data['pub_date'].toString().split('T')[1].split('.')[0].split(':')[0]+'시 '+data['pub_date'].toString().split('T')[1].split('.')[0].split(':')[1]+'분';          _totalvalue = data['airkorea']['khai'].toInt();
          _total_rate=Ranker(_totalvalue.toDouble(),'khai');
        });
      }
    }
  }
  void getlocation() async {
    Map<String,dynamic> _my_si_gun_gu;
    final response=await http.get(Uri.parse('https://api.vworld.kr/req/data?service=data&request=GetFeature&data=LT_C_ADSIGG_INFO&key=FEA696B3-DA29-3EC5-95F3-5272C2CD83B5&geomFilter=point('+context.read<User>().longitude + ' ' + context.read<User>().latitude + ')'));
    _my_si_gun_gu=jsonDecode(response.body);
    setState((){
      try {_location=_my_si_gun_gu['response']['result']['featureCollection']['features'][0]['properties']['sig_kor_nm'];
      print(_location);
      print(context.read<User>().longitude);
      print(context.read<User>().latitude);
      }
      catch (e) {_location = "";}
    });  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    call_api();
    getlocation();
  }

  Future<void> _refresh() async
  {
    context.read<User>().setLocation(); //airkorea로 데이터 전송은 1분마다 해도 ui의 위치 업그레이드는 최신의 위치를 가져와야 한다.
    call_api();
    getlocation();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _refresh,

        child :ListView(
          children: [
            Container(

                color:Color(0xff19B35D),
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //SizedBox(height:MediaQuery.of(context).size.height*(0.000001),),
                    Left_right_scroll(
                        left_right_scroll_text: left_right_scroll_text),
                    Container(
                      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015), MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015),),
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*(0.025)),
                      height:(MediaQuery.of(context).size.height*(0.45)),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        color: Colors.white,
                        // boxShadow: [
                        //   BoxShadow(
                        //     spreadRadius: 2,
                        //     color: Colors.grey,
                        //     offset: Offset(2, 3),
                        //     blurRadius: 1.5,
                        //   )
                        // ],
                      ),
                      child :Column(
                        children: [
                          SizedBox(
                              width:MediaQuery.of(context).size.width,
                              height:MediaQuery.of(context).size.height*(0.27),
                              child:Total_pannel(scale: 1.1,
                                  totalvalue: _totalvalue.toDouble(),
                                  total_rate: _total_rate,
                                  name_of_evaluate: (widget.is_inside ? '초미세먼지농도' : 'AQI'),
                                  unit: (widget.is_inside ? '㎍/㎥' : '통합공기지수'),text_size: 12,width:200,total_rate_size:15) ),
                          SizedBox(height:MediaQuery.of(context).size.height*(0.018)),
                          User_Text(username: context
                              .read<User>()
                              .user_id, car_number : context.read<User>().car_number,location: _location, datetime: _datetime),

                        ],
                      ),

                    ),

                    Container(
                      margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015), MediaQuery.of(context).size.height*(0.017), MediaQuery.of(context).size.height*(0.015),),
                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*(0.025)),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        color: Colors.white,
                        // boxShadow: [
                        //   BoxShadow(
                        //     spreadRadius: 2,
                        //     color: Colors.grey,
                        //     offset: Offset(2, 3),
                        //     blurRadius: 1.5,
                        //   )
                        // ],
                      ),
                      child : Variable_pannel_horizontal_listview_pannel(
                          name_lists: name_lists,
                          unit_lists: unit_lists,
                          data: widget.is_inside ? data['sensor'] : data['airkorea']) ,

                    ),
                  ],

                )
            ),
          ],
        )
    );
  }

}

class FilterData {
  String lastfilterchangedate;
  String ShouldChangeFilter;
  Image filter_goodorbad;
  Color filter_color;
  String filter_state_word;
  String filter_state_grade;

  FilterData({required this.lastfilterchangedate, required this.ShouldChangeFilter,required  this.filter_goodorbad,required this.filter_color, required this.filter_state_word, required this.filter_state_grade});

  factory FilterData.fromJson(Map<String, dynamic> json) {
    return FilterData(

      filter_state_grade: json['filter_state_grade'].toString(),
      filter_state_word: json['filter_state_word'],
      // lastfilterchangedate:"2022-01-01",
      // ShouldChangeFilter: "필터 교체 필요",
      // filter_goodorbad:Image.asset('images/good.png',scale : 1.0, fit: BoxFit.cover),
      // filter_color:Colors.green,
      lastfilterchangedate: DateTime.parse(json['lastfilterchangedate']).toString().substring(0,10),
      ShouldChangeFilter: json['filter_state_word']=='좋음' ? "필터가 최신 상태입니다." : json['filter_state_word']=='보통' ? "필터가 사용중입니다..." : "필터를 교체해주세요.",
      filter_goodorbad:json['filter_state_word']=='좋음' ? Image.asset('images/good.png',scale : 1.0, fit: BoxFit.cover) : Image.asset('images/bad.png',scale : 1.0, fit: BoxFit.cover),
      filter_color:json['filter_state_word']=='좋음' ? Colors.green : json['filter_state_word']=='보통' ? Colors.grey : Colors.red,
    );
  }
}
class Page3 extends StatefulWidget{
  const Page3({Key? key}) : super(key: key);
  @override
  State<Page3> createState() => _Page3_State();
}
class _Page3_State extends State<Page3> {

  Future<FilterData>? _filterdata;
  @override
  void initState(){
    super.initState();
    setState((){_filterdata=fetchPost();});
  }
  Future<FilterData> fetchPost() async {
    var yesterday_date = DateTime.now().subtract(Duration(days:1));
    String yesterday_string = yesterday_date.toString().substring(0,10);
    final response =
    await http.get(Uri.parse('https://auton-iot.com/api/filter/?machine='+context.read<User>().machine),
        headers: {'Authorization': 'Token ' + context
        .read<Token_login>()
        .Token});
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return FilterData.fromJson(jsonDecode(response.body));
      //마지막 가장 최신 데이터를 가져온다.
    } else {
      throw Exception('Failed to load post');
    }
  }
  Future<void> _refresh() async
  {
    setState((){_filterdata=fetchPost();});
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
        future:_filterdata,
        builder:(BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData==false)
            {
              return Center(child:CircularProgressIndicator());
            }
          else if(snapshot.hasError)
            {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 15),
                ),
              );
            }
          else {
            return RefreshIndicator(
              onRefresh: _refresh,

              child: ListView(
                children: [
                  Container(

                    color: Color(0xff19B35D),
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,

                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.02),
                        Container(

                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15.0)),
                            color: Colors.white,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                    children: [
                                      Text("마지막 필터 교체 날짜: " + snapshot.data!.lastfilterchangedate,
                                          style: TextStyle(fontSize: 10)),
                                      Text(
                                          snapshot.data!.ShouldChangeFilter, style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                    ]
                                ),
                                Container(
                                  child: snapshot.data!.filter_goodorbad,
                                ),
                              ]
                          ),
                        ),
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.08),
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.9,

                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(15.0)),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.4,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.4,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 10, color: snapshot.data!.filter_color)
                                  ),
                                  child: Center(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          Text(snapshot.data!.filter_state_grade,
                                              style: TextStyle(
                                                  fontSize: 50,
                                                  color: snapshot.data!.filter_color,
                                                  fontWeight: FontWeight.bold)),
                                          Row(

                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Text("필터 성능 ",
                                                    style: TextStyle(
                                                        fontSize: 25)),
                                                Text(snapshot.data!.filter_state_word,
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: snapshot.data!.filter_color,
                                                        fontWeight: FontWeight
                                                            .bold))
                                              ]),
                                        ]
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.05),
                                Text("본 수치는 필터 성능을 나타내는 절대적인 수치는 아님을 알려드립니다.",
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center)
                              ],
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
    }
    );
      }
  }


