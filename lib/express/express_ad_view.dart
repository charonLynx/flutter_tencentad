import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tencentad/flutter_tencentad.dart';

///
/// Description: 描述
/// Author: Gstory
/// Email: gstory0404@gmail.com
/// CreateDate: 2021/8/7 17:33
///
class ExpressAdView extends StatefulWidget {
  final String androidId;
  final String iosId;
  final int viewWidth;
  final int viewHeight;
  final FlutterTencentadExpressCallBack? callBack;

  const ExpressAdView({
    Key? key,
    required this.androidId,
    required this.iosId,
    required this.viewWidth,
    required this.viewHeight,
    this.callBack,
  }) : super(key: key);

  @override
  _ExpressAdViewState createState() => _ExpressAdViewState();
}

class _ExpressAdViewState extends State<ExpressAdView> {
  String _viewType = "com.gstory.flutter_tencentad/NativeExpressAdView";

  MethodChannel? _channel;

  //广告是否显示
  bool _isShowAd = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShowAd) {
      return Container();
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.viewWidth.toDouble(),
        height: widget.viewHeight.toDouble(),
        child: AndroidView(
          viewType: _viewType,
          creationParams: {
            "androidId": widget.androidId,
            "viewWidth": widget.viewWidth,
            "viewHeight": widget.viewHeight,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        width: widget.viewWidth.toDouble(),
        height: widget.viewHeight.toDouble(),
        child: UiKitView(
          viewType: _viewType,
          creationParams: {
            "iosId": widget.iosId,
            "viewWidth": widget.viewWidth,
            "viewHeight": widget.viewHeight,
          },
          onPlatformViewCreated: _registerChannel,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      return Container();
    }
  }

  //注册cannel
  void _registerChannel(int id) {
    _channel = MethodChannel("${_viewType}_$id");
    _channel?.setMethodCallHandler(_platformCallHandler);
  }

  //监听原生view传值
  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      //显示广告
      case FlutterTencentadMethod.onShow:
        if (mounted) {
          setState(() {
            _isShowAd = true;
          });
        }
        widget.callBack?.onShow!();
        break;
      //广告加载失败
      case FlutterTencentadMethod.onFail:
        if (mounted) {
          setState(() {
            _isShowAd = false;
          });
        }
        Map map = call.arguments;
        widget.callBack?.onFail!(map["code"], map["message"]);
        break;
      //点击
      case FlutterTencentadMethod.onClick:
        widget.callBack?.onClick!();
        break;
      //曝光
      case FlutterTencentadMethod.onExpose:
        widget.callBack?.onExpose!();
        break;
      //关闭
      case FlutterTencentadMethod.onClose:
        if (mounted) {
          setState(() {
            _isShowAd = false;
          });
        }
        widget.callBack?.onClose!();
        break;
    }
  }
}
