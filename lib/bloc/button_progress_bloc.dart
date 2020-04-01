import 'dart:async';

enum ActionButtonProgress{
  GET,
  GETTING,
}

class ButtonProgressBloc{
  final String _defaultText = 'Get';
  String _processingText = 'Getting';
  bool isProcessing = true;

  StreamController<String> _processController = StreamController<String>();
  StreamSink<String> get _processSink => _processController.sink;
  Stream<String> get processStream => _processController.stream;

  StreamController<ActionButtonProgress> _actionProgress = StreamController<ActionButtonProgress>();
  Sink<ActionButtonProgress> get actionSink => _actionProgress.sink;

  ButtonProgressBloc(){
    _actionProgress.stream.listen(_mapEventToState);
  }

  void _mapEventToState(ActionButtonProgress buttonProgress){
    switch(buttonProgress){
      case ActionButtonProgress.GET :
        _processSink.add('$_processingText');
        isProcessing = false;
        break;
      case ActionButtonProgress.GETTING :
        _processSink.add('$_defaultText');
        isProcessing = true;
        break;
    }
  }


  void dispose(){
    _processController.close();
    _processSink.close();
    _actionProgress.close();
    actionSink.close();
  }
}