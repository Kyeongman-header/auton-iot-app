import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'ranker.dart';


class Time_Sensor {
  final String Time;
  final double sensor;

  Time_Sensor({required this.Time, required this.sensor});
}

class GroupedBarChart extends StatelessWidget {
  final List<charts.Series<Time_Sensor, String>> seriesList;
  final bool animate;


  GroupedBarChart({required this.seriesList, required this.animate});
  factory GroupedBarChart.withSampleData(List data_1,List data_2, bool is_average,int one_seven_thirty) {
    return new GroupedBarChart(
      seriesList: _createSampleData(data_1,data_2,is_average,one_seven_thirty), animate: true,
    );
  }
  //data_1은 센서, data_2는 airkorea이다.
  static List<charts.Series<Time_Sensor, String>> _createSampleData(List data_1,List data_2,bool is_average, int one_seven_thirty) {
    final List<Time_Sensor> inside = [];
    final List<Time_Sensor> outside = [];
    bool first=false;
    switch(one_seven_thirty){
      case 0 :
        {


          if (data_1.isNotEmpty && data_2.isNotEmpty)
          {
            var len=(data_1.length < data_2.length) ? data_1.length : data_2.length;
            for(int i =0 ; i<len ; i++)
            {
              DateTime sensor_first_Date=DateTime.parse(data_1[i]['pub_date'].split('T')[0]+' '+data_1[i]['pub_date'].split('T')[1].split(':')[0]);
              DateTime airkorea_first_Date=DateTime.parse(data_2[i]['pub_date'].split('T')[0]+' '+data_2[i]['pub_date'].split('T')[1].split(':')[0]);
              if (sensor_first_Date.isAtSameMomentAs(airkorea_first_Date))
              {
                continue;
              }
              else if(sensor_first_Date.isAfter(airkorea_first_Date))
              {
                first=false;
              }
              else
              {
                first=true;
              }
            }

            for(int i=0; i<data_1.length; i++) {
              inside.add(new Time_Sensor(
                  Time: data_1[i]['pub_date'].split('T')[1].substring(0, 2)+ "시",
                  sensor: data_1[i][is_average ? 'hours' : 'hours_worst']));
            }
            for(int i=0; i<data_2.length; i++) {
              outside.add(new Time_Sensor(
                  Time: data_2[i]['pub_date'].split('T')[1].substring(0, 2)+ "시",
                  sensor: data_2[i][is_average
                      ? 'hours'
                      : 'hours_worst'].toDouble()));
            }
          }
          else if(data_1.isEmpty && data_2.isNotEmpty)
          {
            for(int i=0; i<data_2.length; i++) {
              inside.add(new Time_Sensor(
                  Time: data_2[i]['pub_date'].split('T')[1].substring(0, 2)+ "시",
                  sensor: 0));
              outside.add(new Time_Sensor(
                  Time: data_2[i]['pub_date'].split('T')[1].substring(0, 2)+ "시",
                  sensor: data_2[i][is_average
                      ? 'hours'
                      : 'hours_worst'].toDouble()));
            }
          }
          else if(data_1.isNotEmpty && data_2.isEmpty)
          {
            for(int i=0; i<data_2.length; i++) {
              inside.add(new Time_Sensor(
                  Time: data_1[i]['pub_date'].split('T')[1].substring(0, 2) + "시",
                  sensor: data_1[i][is_average
                      ? 'hours'
                      : 'hours_worst'].toDouble()));
              outside.add(new Time_Sensor(Time: data_1[i]['pub_date'].split('T')[1].substring(0, 2)+ "시",
                  sensor: 0));
            }
          }
          else
          {
            inside.add(new Time_Sensor(Time:"데이터가 아직 없습니다",sensor: 0));
            outside.add(new Time_Sensor(Time:"데이터가 아직 없습니다",sensor: 0));
          }

          break;
        }
      case 1 :
        {
          //센서.

          if (data_1.isNotEmpty && data_2.isNotEmpty) {
            var len=(data_1.length < data_2.length) ? data_1.length : data_2.length;
            for(int i =0 ; i<len ; i++) {
              DateTime sensor_first_Date = DateTime.parse(
                  data_1[i]['pub_date'].split('T')[0] );
              DateTime airkorea_first_Date = DateTime.parse(
                  data_2[i]['pub_date'].split('T')[0] );
              if(sensor_first_Date.isAtSameMomentAs(airkorea_first_Date))
              {
                continue;
              }
              else if (sensor_first_Date.isAfter(airkorea_first_Date)) {
                first = false;
              }
              else {
                first = true;
              }
            }
            for (int i = 0; i < data_1.length; i++) {
              inside.add(new Time_Sensor(Time: DateTime
                  .parse(data_1[i]['pub_date'])
                  .month
                  .toString() + "월" + DateTime
                  .parse(data_1[i]['pub_date'])
                  .day
                  .toString() + "일",
                  sensor: data_1[i][is_average ? 'days' : 'days_worst']
                      .toDouble()));
            }
            for (int i = 0; i < data_2.length; i++) {
              outside.add(new Time_Sensor(Time: DateTime
                  .parse(data_2[i]['pub_date'])
                  .month
                  .toString() + "월" + DateTime
                  .parse(data_2[i]['pub_date'])
                  .day
                  .toString() + "일",
                  sensor: data_2[i][is_average
                      ? 'days'
                      : 'days_worst'].toDouble()));
            }

          }
          else if(data_1.isEmpty &&data_2.isNotEmpty) {
            for (int i = 0; i < data_2.length; i++) {
              inside.add(new Time_Sensor(Time: DateTime
                  .parse(data_2[i]['pub_date'])
                  .month
                  .toString() + "월" + DateTime
                  .parse(data_2[i]['pub_date'])
                  .day
                  .toString() + "일", sensor: 0));
              outside.add(new Time_Sensor(Time:   DateTime
                  .parse(data_2[i]['pub_date'])
                  .month
                  .toString() + "월" + DateTime
                  .parse(data_2[i]['pub_date'])
                  .day
                  .toString() + "일",
                  sensor: data_2[i][is_average
                      ? 'days'
                      : 'days_worst'].toDouble()));
            }
          }
          else if(data_1.isNotEmpty && data_2.isEmpty)
          {
            for (int i = 0; i < data_1.length; i++) {
              inside.add(new Time_Sensor(Time: DateTime
                  .parse(data_1[i]['pub_date'])
                  .month
                  .toString() + "월" + DateTime
                  .parse(data_1[i]['pub_date'])
                  .day
                  .toString() + "일",
                  sensor: data_1[i][is_average ? 'days' : 'days_worst']
                      .toDouble()));
              outside.add(new Time_Sensor(Time:   DateTime
                  .parse(data_2[i]['pub_date'])
                  .month
                  .toString() + "월" + DateTime
                  .parse(data_2[i]['pub_date'])
                  .day
                  .toString() + "일",
                  sensor: 0));
            }
          }
          else{
            inside.add(new Time_Sensor(Time:"데이터가 아직 없습니다",sensor: 0));
            outside.add(new Time_Sensor(Time:"데이터가 아직 없습니다",sensor: 0));
          }


          break;
        }
      case 2 :
        {
          //센서.

          if (data_1.isNotEmpty && data_2.isNotEmpty) {
            if (data_1.isNotEmpty && data_2.isNotEmpty) {
              var len = (data_1.length < data_2.length) ? data_1.length : data_2
                  .length;
              for (int i = 0; i < len; i++) {
                DateTime sensor_first_Date = DateTime.parse(
                    data_1[i]['pub_date'].split('T')[0]);
                DateTime airkorea_first_Date = DateTime.parse(
                    data_2[i]['pub_date'].split('T')[0]);

                if (sensor_first_Date.isAtSameMomentAs(airkorea_first_Date)) {
                  continue;
                }
                else if (sensor_first_Date.isAfter(airkorea_first_Date)) {
                  first = false;
                }
                else {
                  first = true;
                }
              }
              for (int i = 0; i < data_1.length; i++) {
                inside.add(new Time_Sensor(Time: DateTime
                    .parse(data_1[i]['pub_date'])
                    .month
                    .toString() + "월" + DateTime
                    .parse(data_1[i]['pub_date'])
                    .day
                    .toString() + "일",
                    sensor: data_1[i][is_average ? 'weeks' : 'weeks_worst']
                        .toDouble()));
              }
              for (int i = 0; i < data_2.length; i++) {
                outside.add(new Time_Sensor(Time: DateTime
                    .parse(data_2[i]['pub_date'])
                    .month
                    .toString() + "월" + DateTime
                    .parse(data_2[i]['pub_date'])
                    .day
                    .toString() + "일",
                    sensor: data_2[i][is_average
                        ? 'weeks'
                        : 'weeks_worst'].toDouble()));
              }
            }
            else if (data_1.isEmpty && data_2.isNotEmpty) {
              for (int i = 0; i < data_2.length; i++) {
                inside.add(new Time_Sensor(Time: DateTime
                    .parse(data_2[i]['pub_date'])
                    .month
                    .toString() + "월" + DateTime
                    .parse(data_2[i]['pub_date'])
                    .day
                    .toString() + "일", sensor: 0));
                outside.add(new Time_Sensor(Time: DateTime
                    .parse(data_2[i]['pub_date'])
                    .month
                    .toString() + "월" + DateTime
                    .parse(data_2[i]['pub_date'])
                    .day
                    .toString() + "일",
                    sensor: data_2[i][is_average
                        ? 'weeks'
                        : 'weeks_worst'].toDouble()));
              }
            }
            else if (data_1.isNotEmpty && data_2.isEmpty) {
              for (int i = 0; i < data_1.length; i++) {
                inside.add(new Time_Sensor(Time: DateTime
                    .parse(data_1[i]['pub_date'])
                    .month
                    .toString() + "월" + DateTime
                    .parse(data_1[i]['pub_date'])
                    .day
                    .toString() + "일",
                    sensor: data_1[i][is_average ? 'weeks' : 'weeks_worst']
                        .toDouble()));
                outside.add(new Time_Sensor(Time: DateTime
                    .parse(data_2[i]['pub_date'])
                    .month
                    .toString() + "월" + DateTime
                    .parse(data_2[i]['pub_date'])
                    .day
                    .toString() + "일",
                    sensor: 0));
              }
            }
            else {
              inside.add(new Time_Sensor(Time: "데이터가 아직 없습니다", sensor: 0));
              outside.add(new Time_Sensor(Time: "데이터가 아직 없습니다", sensor: 0));
            }

          }
          break;
        }
      default :
        break;

    }

    return first ? [
      new charts.Series<Time_Sensor, String>(
        id: 'inside',
        domainFn: (Time_Sensor sales, _) => sales.Time,
        measureFn: (Time_Sensor sales, _) => sales.sensor,
        data: inside,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.lightGreen),

      ),
      new charts.Series<Time_Sensor, String>(
        id: 'outside',
        domainFn: (Time_Sensor sales, _) => sales.Time,
        measureFn: (Time_Sensor sales, _) => sales.sensor,
        data: outside,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.grey),
      ),
    ] : [

      new charts.Series<Time_Sensor, String>(
        id: 'outside',
        domainFn: (Time_Sensor sales, _) => sales.Time,
        measureFn: (Time_Sensor sales, _) => sales.sensor,
        data: outside,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.grey),
      ),
      new charts.Series<Time_Sensor, String>(
        id: 'inside',
        domainFn: (Time_Sensor sales, _) => sales.Time,
        measureFn: (Time_Sensor sales, _) => sales.sensor,
        data: inside,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.lightGreen),

      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      //primaryMeasureAxis: charts.NumericAxisSpec(viewport: charts.NumericExtents(0.0,100.0)),
      barGroupingType: charts.BarGroupingType.grouped,

      behaviors: [
        // Add the sliding viewport behavior to have the viewport center on the
        // domain that is currently selected.
        //new charts.SlidingViewport(),
        // A pan and zoom behavior helps demonstrate the sliding viewport
        // behavior by allowing the data visible in the viewport to be adjusted
        // dynamically.
        charts.PanAndZoomBehavior(),
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(

            // Tick and Label styling here.
              labelStyle: charts.TextStyleSpec(

              ),

              // Change the line colors to match text color.
              lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.black))),
    );

    // Set an initial viewport to demonstrate the sliding viewport behavior on
    // initial chart load.
    //domainAxis: charts.OrdinalAxisSpec(
    //viewport: charts.OrdinalViewport('23', 3)),
  }
}
class Error_page extends StatelessWidget{
  @override
  build(BuildContext context){
    return Container(
        color:Color(0xff00AB4C),
        child : Center(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children : <Widget> [
              Icon(Icons.error_outline,color: Colors.white),
              Text('이 페이지는 아직 준비되지 않았습니다.',style : TextStyle(fontFamily: 'NotoSansKR',color: Colors.white),),
            ],
          ),

        )
    );
  }
}
// class Graph_inside_outside extends StatelessWidget{
//
// }

class Date_DateRange_Picker extends StatefulWidget {
  final int page;
  final Function(DateTime ) setdate;
  //const Date_DateRange_Picker({required this.page,required this.date,required this.sevenRange,required this.thirtyRange,});
  const Date_DateRange_Picker({Key? key, required this.page, required this.setdate }) : super(key: key);
  @override
  State<Date_DateRange_Picker> createState() => _Date_DateRange_Picker_State();
}
class _Date_DateRange_Picker_State extends State<Date_DateRange_Picker>
{

  DateTime? _date=DateTime.now(); //일일 통계를 확인할 날짜.
  DateTime? temp=DateTime.now();

  @override
  void didChangeDependencies(){
    _date == null ? (_date=temp) : (temp=_date!);
  }
  @override
  Widget build(BuildContext context){


    return InkWell(
        onTap:
            (){
          Future<DateTime?> selectedDate=showDatePicker(
            context:context,
            initialDate: _date == null ? (temp!) : (_date!),
            firstDate: DateTime(2020),
            lastDate: DateTime(2025),
          );
          selectedDate.then((dateTime){
            dateTime == null ? dateTime=_date : _date=dateTime;
            widget.setdate(dateTime!); // 상위에서 다시 build 할거기 때문에 굳이 setState를 해줄 필요가 없다.
          });
        },
        child: Container(
          // alignment: Alignment.center,
          width: 100,
          height:MediaQuery.of(context).size.height*(0.03),
          decoration: BoxDecoration(
            border: Border.all(
              width:1.5,
              color:Colors.white,
            ),
          ),
          child: Text(
            _date!=null ? "${_date.toString().split(' ')[0]}" : "${temp.toString().split(' ')[0]}",
            textAlign: TextAlign.center,
            style : TextStyle(fontFamily: 'NotoSansKR',color: Colors.white),

          ),
        )


    );

  }
}

class Variable_pannel_horizontal_listview_pannel extends StatelessWidget{
  List<String> name_lists=["온도","습도","CO2","초미세먼지"];
  List<String> unit_lists=["℃","％","ppm","㎍/㎥"];
  Map<String,dynamic> data;
  List<Widget> row = [];
  Variable_pannel_horizontal_listview_pannel({required this.name_lists, required this.unit_lists, required this.data});

  @override
  Widget build(BuildContext context){
    if (data!=null) {
      for (int i = 0; i < name_lists.length; i++) {
        row.add(Total_pannel(scale: 3.0,
            totalvalue: data[name_lists[i]].toDouble(),
            name_of_evaluate: name_lists[i],
            total_rate: Ranker(data[name_lists[i]].toDouble(),name_lists[i]),
            unit: unit_lists[i],text_size: 10,width:120,total_rate_size:12));
      }
    }
    else{ return CircularProgressIndicator();}
    return Container(
      //margin: EdgeInsets.symmetric( horizontal : 20.0),
        height: MediaQuery.of(context).size.height*0.2,

        child: Scrollbar(
            isAlwaysShown: true,
            controller: ScrollController(initialScrollOffset: 0.0, keepScrollOffset:true,),
            child : ListView(
              scrollDirection: Axis.horizontal,
              children : row,
            )
        )
    );
  }
}
class Total_pannel extends StatelessWidget{
  double totalvalue;
  String total_rate;
  String name_of_evaluate;
  String unit;
  double scale=3.0;
  double text_size=10.0;
  double total_rate_size=12;
  double width=100;
  Color total_rate_color=Colors.black;
  Image pannel = Image.asset('images/pannelgood.png',scale : 3.0, fit: BoxFit.cover);
  Total_pannel({required this.totalvalue, required this.total_rate, required this.name_of_evaluate,required this.unit,required this.scale, required this.text_size,required this.width,required this.total_rate_size});
  @override
  Widget build(BuildContext context){
    //print(scale.toString());
    switch(total_rate) {
      case ('쾌적') :
        pannel=Image.asset('images/pannelgood.png',scale : scale,);
        total_rate_color=Colors.green;
        break;
      case '주의' :
        pannel=Image.asset('images/pannelsoso.png',scale : scale);
        total_rate_color=Colors.orange;
        break;
      case '위험' :
        pannel=Image.asset('images/pannelbad.png',scale : scale,);
        total_rate_color=Colors.black45;
        break;
      case '매우 위험' :
        pannel=Image.asset('images/pannelverybad.png',scale : scale,);
        total_rate_color=Colors.red;
        break;
      default :
        pannel=Image.asset('images/pannelgood.png',scale : scale,);

    }
    switch(name_of_evaluate){
      case('temperature'):
        name_of_evaluate='온도';
        break;
      case('humidity'):
        name_of_evaluate='습도';
        break;
      case('CO2'):
        name_of_evaluate='이산화탄소 농도';
        break;
      case('P.M 2.5'):
        name_of_evaluate='초미세먼지 농도';
        break;
      case('CO'):
        name_of_evaluate='일산화탄소 농도';
        break;
      case('SO2'):
        name_of_evaluate='이산화황 농도';
        break;
      case('NO2'):
        name_of_evaluate='이산화질소 농도';
        break;
      case('O3'):
        name_of_evaluate='오존 농도';
        break;
      case('khai'):
        name_of_evaluate='AQI';
        break;
      default:
        break;
    }
    return Container(
        decoration: BoxDecoration(

        ),

        child:  Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pannel,
            Container(
              height:MediaQuery.of(context).size.height*0.05,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width:width,child:Text(totalvalue.toString(),textAlign:TextAlign.center,style: TextStyle(fontFamily: 'NotoSansKR',fontSize:text_size))),

                  SizedBox(width:width,child: Text(name_of_evaluate + '('+unit +')',textAlign:TextAlign.center,style: TextStyle(fontFamily: 'NotoSansKR',fontSize:text_size)),),
                ],
              ),
            ),
            Text(total_rate,style: TextStyle(fontFamily: 'NotoSansKR',fontSize:total_rate_size,fontWeight:FontWeight.bold,color:total_rate_color)),
          ],
        )
    );
  }
}
class User_Text extends StatelessWidget{
  String username = '임시';
  String location = '';
  String car_number = '';
  String datetime='';
  User_Text({required this.username, required this.car_number, required this.location,required this.datetime});
  @override
  Widget build(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children : [
            Text(username + '님',style : const TextStyle(fontFamily: 'NotoSansKR',fontSize: 20),),
            //car_number!=null ? Text(car_number, style : const TextStyle(fontWeight:FontWeight.bold,fontSize: 14),) : SizedBox(height: MediaQuery.of(context).size.height*(0.007)),
            SizedBox(height: MediaQuery.of(context).size.height*(0.007)),
            Text('자동차 공기질',style : const TextStyle(fontFamily: 'NotoSansKR',fontSize: 20),),
          ],
        ),
        Column(
          crossAxisAlignment : CrossAxisAlignment.end,
          children : [
            Text(location,style:TextStyle(fontFamily: 'NotoSansKR',fontWeight:FontWeight.bold)),
            Text('last update : ',style:TextStyle(fontFamily: 'NotoSansKR',fontWeight:FontWeight.w300)),
            Text(datetime,style : TextStyle(fontFamily: 'NotoSansKR',),),
          ],
        ),
      ],
    );
  }
}
class Left_right_scroll extends StatelessWidget {
  String left_right_scroll_text;

  Left_right_scroll({required this.left_right_scroll_text});
  @override
  Widget build(BuildContext context){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width:MediaQuery.of(context).size.width*0.000001),
          Icon(Icons.arrow_back_ios,size:MediaQuery.of(context).size.height*(0.065),color:Colors.white),
          FittedBox(fit:BoxFit.fitWidth,child:Text(left_right_scroll_text,style:TextStyle(fontFamily: 'NotoSansKR',fontSize:MediaQuery.of(context).size.height*(0.035),color:Colors.white)),),
          Icon(Icons.arrow_forward_ios,size:MediaQuery.of(context).size.height*(0.065),color:Colors.white),
          SizedBox(width:MediaQuery.of(context).size.width*0.000001),
        ]
    );
  }
}

