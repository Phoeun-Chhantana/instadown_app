import 'package:flutter/material.dart';
import 'package:instadown_app/bloc/button_progress_bloc.dart';

class RaisedButtonProgress extends StatelessWidget{

  //ButtonProgressBloc _progressBloc = new ButtonProgressBloc();
  final Widget child;
  VoidCallback onPressed;

  RaisedButtonProgress({this.onPressed, this.child});

//  _testing() async{
//    _progressBloc.actionSink.add(ActionButtonProgress.GET);
//    await Future.delayed(const Duration(seconds: 5));
//    _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
//    print('Done');
//  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
//      child: StreamBuilder<String>(
//        stream: _progressBloc.processStream,
//        builder: (context, snapshot){
//          if(snapshot.hasData){
//            return Text('${snapshot.data}');
//          }
//          return const Text('Get');
//        },
//      ),
      child: child,
      color: Colors.green,
      textColor: Colors.white,
      onPressed: onPressed,
      disabledTextColor: Colors.white.withAlpha(120),
    );
  }
}

class OutlineButtonProgress extends StatelessWidget{

  final Widget child;
  VoidCallback onPressed;

  OutlineButtonProgress({this.onPressed, this.child});

//  _testing() async{
//    _progressBloc.actionSink.add(ActionButtonProgress.GET);
//    await Future.delayed(const Duration(seconds: 5));
//    _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
//    print('Done');
//  }

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
//      child: StreamBuilder<String>(
//        stream: _progressBloc.processStream,
//        builder: (context, snapshot){
//          if(snapshot.hasData){
//            return Text('${snapshot.data}');
//          }
//          return const Text('Get');
//        },
//      ),
      child: child,
      onPressed: onPressed,
      disabledTextColor: Colors.white.withAlpha(120),
    );
  }
}