import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

enum WidgetType{
  TYPE_SINGLE,
  TYPE_MULTI
}

class WidgetNotifier extends ChangeNotifier{

  List<Widget> _imageWidgets = new List<Widget>();
  WidgetType _type;

  void add(Widget imageWidget){
    _imageWidgets.add(imageWidget);
    if(_imageWidgets.length == 1){
      _type = WidgetType.TYPE_SINGLE;
    }else _type = WidgetType.TYPE_MULTI;
    notifyListeners();
  }

  List<Widget> get getImageWidgets => _imageWidgets;

  void clearWidget(){
    if(_imageWidgets.isNotEmpty){
      _imageWidgets.clear();
      notifyListeners();
    }
  }

  WidgetType get getWidgetType => _type;

//  Widget loadImageSingle(String userId){
//    notifyListeners();
//    return Column(
//      children: <Widget>[
//        Expanded(
//          flex: 2,
//          child: Image.network(
//            'https://instagram.com/p/$userId/media/?size=l', width: 300, height: 300,
//            frameBuilder: (context, child, frame, wasSynchronouslyLoaded){
//              return Center(child: frame == null ?
//              const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation(Colors.lightBlue)) : child);
//            },
//          ),
//        ),
//        //const SizedBox(height: 20),
//        OutlineButton(
//          onPressed: (){
//
//          },
//          child: const Text('Save'),
//        ),
//      ],
//    );
//  }

//  Widget loadMultiImage(String url){
//    notifyListeners();
////    return Image.network(
////      '$url', width: 300, height: 300,
////      frameBuilder: (context, child, frame, wasSynchronouslyLoaded){
////        return Center(child: frame == null ?
////        const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation(Colors.lightBlue)) : child);
////      },
////    );
//    return Column(
//      children: <Widget>[
//        Expanded(
//          flex: 2,
//          child: Image.network(
//            '$url', width: 300, height: 300,
//            frameBuilder: (context, child, frame, wasSynchronouslyLoaded){
//              return Center(child: frame == null ?
//              const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation(Colors.lightBlue)) : child);
//            },
//          ),
//        ),
//        //const SizedBox(height: 20),
//        OutlineButton(
//          onPressed: (){
//
//          },
//          child: const Text('Save'),
//        ),
//      ],
//    );
//  }
//
}