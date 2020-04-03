import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instadown_app/model/insta_model.dart';
import 'package:provider/provider.dart';
import 'package:instadown_app/provider/widget_notifier.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:instadown_app/common_widget/button_progress.dart';
import 'package:instadown_app/bloc/button_progress_bloc.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget{
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{

  TextEditingController _editingController;

  AnimationController _animationController;
  ButtonProgressBloc _progressBloc;

  final String _regExPatternForUrl = r'^[{h}]{1}[{t}]{2}[{p}][{s}][{:}][{/}]{2}[w]{3}[.][{i,n,s,t,a,g,r,a,m,.,c,o,m,/,p,/}]{16}\D+';

  Image _image;
  ValueNotifier<int> _selectedIndexOnPageView;
  
  @override
  void initState() {
    _editingController = TextEditingController();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..animateBack(0.5)..animateTo(1, curve: Curves.bounceOut);

    _progressBloc = ButtonProgressBloc();

    _selectedIndexOnPageView = new ValueNotifier(0);

    super.initState();
  }

  _onPressed(){
    if(_editingController.text.isNotEmpty){
      if(_checkURLValidation('${_editingController.text}')){
        _progressBloc.actionSink.add(ActionButtonProgress.GET);
        _fetchContent('${_editingController.text}');
        FocusScope.of(context).unfocus();
        Provider.of<WidgetNotifier>(context).clearWidget();
      }
    }
  }

  @override
  void dispose() {
    _editingController.dispose();
    _animationController.dispose();
    _progressBloc.dispose();
    _selectedIndexOnPageView.dispose();
    super.dispose();
  }

  Widget _childBody(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Container(
            constraints: BoxConstraints(
              maxWidth: 345,
              maxHeight: 50,
            ),
            child: CupertinoTextField(
              controller: _editingController,
              placeholder: 'Instagram\'s link',
              placeholderStyle: const TextStyle(
                letterSpacing: 1.5,
              ),
              style: TextStyle(color: Colors.white.withAlpha(150)),
              clearButtonMode: OverlayVisibilityMode.editing,
              cursorRadius: const Radius.circular(8.0),
              cursorColor: Colors.white38,
              textInputAction: TextInputAction.go,
              onSubmitted: (v){
                if(v.isNotEmpty){
                  if(_checkURLValidation(v)){
                    _progressBloc.actionSink.add(ActionButtonProgress.GET);
                    _fetchContent('${_editingController.text}');
                    Provider.of<WidgetNotifier>(context).clearWidget();
                  }
                  else return;
                }
              },
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8.0)
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _animationController,
            child: StreamBuilder<String>(
              stream: _progressBloc.processStream,
              builder: (context, snapshot){
                return RaisedButtonProgress(
                  onPressed: _progressBloc.isProcessing ? _onPressed : null,
                  child: snapshot.hasData ? Text('${snapshot.data}') : const Text('Get'),
                );
              },
            )
          ),
        ],
      ),
    );
  }

  bool _checkURLValidation(String url){
    final regExp = new RegExp(_regExPatternForUrl);
    return regExp.hasMatch('$url');
  }

  _fetchContent(String url) async{
    try{
      //final result = await http.get('https://www.instagram.com/p/B8liuDXhkiaWX57HpetF6K-0uqS-qAZXET0LfA0/');
      final result = await http.get('$url');
      if(result.statusCode == 200){
        final body = result.body.split('\n');
        //final str = 'window.__additionalDataLoaded(\'/p/B-OrEXBh5Lr/\',';
        for(int i = 0; i < body.length; i++){
          if(body.elementAt(i).contains('config')){
            final int lastIndex = body.elementAt(i).lastIndexOf('</script>'.toString());
            try{
              final model = InstaModel.fromJson(json.decode(body.elementAt(i).substring(52, lastIndex - 1)));
              final edges = model.entryData.postPages.elementAt(0).graphql.shortCodeMedia.sidecarToChildren.edges;
              final isPrivate = model.entryData.postPages.elementAt(0).graphql.shortCodeMedia.owner.is_private;
              if(edges.isNotEmpty && !isPrivate){
                _fetchMultiImage(edges);
                break;
              }
            }catch(e){
              body.forEach((v){
                if(v.contains('"is_private":true')){
                  _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
                  print(v);
                }
                else if(v.contains('"is_private":false')){
                  final index = _editingController.text.indexOf('p/');
                  final lastIndex = _editingController.text.lastIndexOf('/?');
                  final userId = _editingController.text.substring(index + 2, lastIndex);
                  _fetchImageSingle('$userId');
                }
              });
            }
          }
        }
      }
      else{
        _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
        print('account is private');
      }
    }on SocketException catch(e){
      _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
    } on HttpException catch(e){
      _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
      print(e.message);
    } on Exception catch(e){
      _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
      print(e.toString());
    }
  }

  _fetchImageSingle(String userId){
    Provider.of<WidgetNotifier>(context).add(_buildImagePreview(userId: '$userId', type: WidgetType.TYPE_SINGLE));
    _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
    _editingController.clear();
  }

  _fetchMultiImage(List<Edges> edges){
    edges.forEach((url){
      Provider.of<WidgetNotifier>(context).add(_buildImagePreview(url: '${url.node.resources.elementAt(2).src}', type: WidgetType.TYPE_MULTI));
    });
    _progressBloc.actionSink.add(ActionButtonProgress.GETTING);
    _editingController.clear();
  }

//  Widget get _buildLostConnection{
//    return Container(
//      width: double.infinity,
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Image.asset('assets/error404.png', repeat: ImageRepeat.noRepeat),
//          const Text('Seems like you don\'t have an active internet \nconnection'),
//        ],
//      ),
//    );
//  }

//  Future<PermissionStatus> _checkPermissionHandler() async{
//    final result = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
//    return result;
//  }

  Future<Map<PermissionGroup, PermissionStatus>> _requestPermission() async{
    if(Platform.isIOS){
      final result = await PermissionHandler().requestPermissions(
          [PermissionGroup.photos]);
      return result;
    }
    else if(Platform.isAndroid){
      final result = await PermissionHandler().requestPermissions(
          [PermissionGroup.storage]);
      return result;
    }
    else return null;
  }

//  _saveToLocalDevice(Uint8List imageBytes) async{
//    await ImageGallerySaver.saveImage(imageBytes);
//    print(imageBytes);
//    //Image(image: AssetImage(''));
//  }
//
//  Future<http.Response> _loadFromUrl({String userId, String url}) async{
////    final result = await _requestPermission();
////    if(Platform.isIOS){
////      if(Provider.of<WidgetNotifier>(context).getWidgetType == WidgetType.TYPE_SINGLE){
////        if(result[PermissionGroup.storage] == PermissionStatus.granted){
////          final response = await http.get('https://instagram.com/p/$userId/media/?size=l');
////          _saveToLocalDevice(response.bodyBytes);
////          print('user granted');
////          return response;
////        }else print('user denied');
////      }
////      else{
////        if(result[PermissionGroup.storage] == PermissionStatus.granted){
////          final response = await http.get('$url');
////          _saveToLocalDevice(response.bodyBytes);
////          print('user granted');
////        }else print('user denied');
////      }
////    }
////    else if(Platform.isAndroid){
////      if(Provider.of<WidgetNotifier>(context).getWidgetType == WidgetType.TYPE_SINGLE){
////        if(result[PermissionGroup.storage] == PermissionStatus.granted){
////          final response = await http.get('https://instagram.com/p/$userId/media/?size=l');
//////          _saveToLocalDevice(response.bodyBytes);
////          print('user granted');
////        }else print('user denied');
////      }
////      else{
////        if(result[PermissionGroup.storage] == PermissionStatus.granted){
////          final response = await http.get('$url');
////          if(response.statusCode == 200){
////            _saveToLocalDevice(response.bodyBytes);
////            return response;
////          }
////          print('user granted');
////        }else print('user denied');
////      }
////    }
//    if(Provider.of<WidgetNotifier>(context).getWidgetType == WidgetType.TYPE_MULTI){
//      final response = await http.get('$url');
//      if(response.statusCode == 200){
//        _saveToLocalDevice(response.bodyBytes);
//        return response;
//      }
//    }else{
//      final response = await http.get('https://instagram.com/p/$userId/media/?size=l');
//      if(response.statusCode == 200){
//        _saveToLocalDevice(response.bodyBytes);
//        return response;
//      }
//    }
//    return null;
//  }

//  Widget _buildImageSingle(String userId){
//    return Column(
//      children: <Widget>[
//        Expanded(
//          flex: 2,
//          child: Image.network(
//            'https://instagram.com/p/$userId/media/?size=l', width: 300, height: 300,
//            frameBuilder: (context, child, frame, wasSynchronouslyLoaded){
//              return Center(child: frame == null ?
//              const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation(Colors.lightBlue)) : Column(
//                children: <Widget>[
//                  child,
//                  OutlineButton(
//                    onPressed: () => _onOutlinePressed(userId: '$userId'),
//                    child: const Text('Save'),
//                  ),
//                ],
//              ));
//            },
//          ),
//        ),
//      ],
//    );
//  }
//
//  Widget _buildMultiImage(String url){
//    return Column(
//      children: <Widget>[
//        Expanded(
//          flex: 2,
//          child: Image.network(
//            '$url', width: 300, height: 300,
//            frameBuilder: (context, child, frame, wasSynchronouslyLoaded){
//              return Center(child: frame == null ?
//              const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation(Colors.lightBlue)) : Column(
//                children: <Widget>[
//                  child,
//                  OutlineButton(
//                    onPressed: () => _onOutlinePressed(url: '$url'),
//                    child: const Text('Save'),
//                  ),
//                ],
//              ));
//            },
//          ),
//        ),
//      ],
//    );
//  }

  Widget _buildImagePreview({String userId, String url, WidgetType type}){
//    _image = Image.network(
//      type == WidgetType.TYPE_SINGLE ? 'https://instagram.com/p/$userId/media/?size=l' : '$url', width: 300, height: 300,
//      frameBuilder: (context, child, frame, wasSynchronouslyLoaded){
//        return Center(child: frame == null ?
//        const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation(Colors.lightBlue)) : Column(
//          children: <Widget>[
//            child,
//            OutlineButton(
//              onPressed: () => _onOutlinePressed(type),
//              child: const Text('Save'),
//            ),
//          ],
//        ));
//      },
//    );
//    return _image;
    _image = Image(
      image: NetworkImage(
        type == WidgetType.TYPE_SINGLE ? 'https://instagram.com/p/$userId/media/?size=l' : '$url'
      ),
      width: 300, height: 300,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return Center(child: frame == null ?
        const CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation(Colors.lightBlue))
            : Column(
          children: <Widget>[
            child,
            OutlineButton(
              onPressed: () => _onOutlinePressed(type),
              child: const Text('Save'),
            ),
          ],
        ));
      }
    );
    return _image;
  }

  void _onImageSaver(ImageInfo info, bool b){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context){
        return AlertDialog(
          content: FutureBuilder<ByteData>(
            future: info.image.toByteData(format: ImageByteFormat.png),
            builder: (context, snapshot){
              if(snapshot.hasData) {
                ImageGallerySaver.saveImage(
                    snapshot.data.buffer.asUint8List(snapshot.data.offsetInBytes, snapshot.data.lengthInBytes));
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Saved'),
                    const SizedBox(width: 20),
                    const Icon(Icons.check_circle, color: Colors.green)
                  ],
                );
              }
              else return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Saving'),
                  const SizedBox(width: 20),
                  const CupertinoActivityIndicator()
                ],
              );
            },
          ),
        );
      }
    );
  }

  _onOutlinePressed(WidgetType type) async{
    final result = await _requestPermission();
    if(Platform.isAndroid){
      //if(result[PermissionGroup.storage] == PermissionStatus.granted) _buildDialog(url: '$url', userId: '$userId');
      if(result[PermissionGroup.storage] == PermissionStatus.granted){
        if(WidgetType.TYPE_MULTI == type){
          final imageWidgets = Provider.of<WidgetNotifier>(context).getImageWidgets;
          (imageWidgets.elementAt(_selectedIndexOnPageView.value) as Image).image.resolve(ImageConfiguration.empty)
              .completer.addListener(ImageStreamListener(_onImageSaver));
        }
        else _image.image.resolve(ImageConfiguration.empty)
            .completer.addListener(ImageStreamListener(_onImageSaver));
      }
    }
    else if(Platform.isIOS){
      //if(result[PermissionGroup.photos] == PermissionStatus.granted) _buildDialog(url: '$url', userId: '$userId');
      if(result[PermissionGroup.storage] == PermissionStatus.granted){
        if(WidgetType.TYPE_MULTI == type){
          final imageWidgets = Provider.of<WidgetNotifier>(context).getImageWidgets;
          (imageWidgets.elementAt(_selectedIndexOnPageView.value) as Image).image.resolve(ImageConfiguration.empty)
              .completer.addListener(ImageStreamListener(_onImageSaver));
        }
        else _image.image.resolve(ImageConfiguration.empty)
            .completer.addListener(ImageStreamListener(_onImageSaver));
      }
      //_image.image.resolve(ImageConfiguration.empty).removeListener(ImageStreamListener(_onImage));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('InstaDown'),
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: const AssetImage('assets/sample2_animted.gif'), fit: BoxFit.fill, repeat: ImageRepeat.noRepeat)
        ),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: _childBody(),
            ),
            Expanded(
              flex: 3,
              child: PageView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index){
                  _selectedIndexOnPageView.value = index;
                  print(index);
                },
                children: Provider.of<WidgetNotifier>(context).getImageWidgets.toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//class Utility{
//  static final String _key = 'IMG_KEY';
//
//  static void saveImageToLocal(String path) async{
//    final prefs = await SharedPreferences.getInstance();
//    prefs.setString(_key, '$path');
//  }
//
//  static void read() async{
//    final prefs = await SharedPreferences.getInstance();
//    print(prefs.getString(_key));
//  }
//
//  static void clear() async{
//    final prefs = await SharedPreferences.getInstance();
//    prefs.clear();
//  }
//}