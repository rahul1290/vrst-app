import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vrst/purchase/bilEntry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrst/common/global.dart' as global;
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vrst/dbhelper.dart';

class BillEntry {
  final String crop;
  final String variety;
  final String quantity;

  BillEntry(this.crop,this.variety, this.quantity);

  @override
  String toString() {
    return 'crop = $crop, variety= $variety, quantity= $quantity';
  }
}