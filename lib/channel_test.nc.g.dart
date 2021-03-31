// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// ChannelHelpGenerator
// **************************************************************************

part of 'channel_test.dart';

class ChannelTestImp implements ChannelTest {
  ChannelTestImp._internal();

  final MethodChannel _MethodChannel = MethodChannel("test");

  static ChannelTest _ChannelTest;

  static ChannelTest getInstance() {
    if (_ChannelTest == null) {
      _ChannelTest = ChannelTestImp._internal() as ChannelTest;
    }
    return _ChannelTest;
  }

  @override
  void test() async {
    dynamic _result = await _MethodChannel.invokeMethod('test');
  }
}
