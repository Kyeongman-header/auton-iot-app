import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class API{
  final String user_id;

  final String Token;
  API({Key? key,required this.user_id,required this.Token});

}
