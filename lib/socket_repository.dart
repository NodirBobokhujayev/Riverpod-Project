import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketRepository {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _controller = StreamController.broadcast();

  Future<void> connect({
    required void Function() onConnected,
    required void Function(dynamic error) onError,
  }) async {
    final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzYwOTYzMzYzLCJpYXQiOjE3NTgzNzEzNjQsImp0aSI6ImI4YzhlN2QyOTlhOTQzZWViMTM0ODJkZjQzZWQ2ZDY4IiwidXNlcl9pZCI6IjEifQ.Ra6RoXYFDtHi7vn8yzQz7VYtIqarPuwqfMTUKswlZwM";
    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse('wss://d40283ed8a42.ngrok-free.app/ws/location/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      _channel!.stream.listen(
            (event) {
          _controller.add(event);
        }, // streamni uzatamiz
        onError: (e) => _controller.addError(e),
        onDone: () => _controller.close(),
      );

      // Exception tutish bloki
      try {
        await _channel?.ready;
        onConnected();

      } catch(e){
        print(e);
        final we = e as WebSocketChannelException;
        final we1 = we.inner as WebSocketException;
        print(we1.message);
      }

      // _subscription = _channel?.stream.listen(
      //       (message) {
      //     print("📩 Received: $message");
      //   },
      //   onError: (error) {
      //     onError(error);
      //   },
      //   onDone: () {
      //     print("🔌 Connection closed");
      //   },
      //   cancelOnError: true,
      // );

    }catch (e) {
      print("❌ Connect exception: $e");
      onError(e);
    }
  }

  Stream<dynamic> get stream => _controller.stream;


  Future<void> sendLocation(dynamic location) async {
    final data = {
      "type": "location",
      "lat": location?.latitude,
      "lng": location?.longitude,
    };
    try{
      _channel?.sink.add(jsonEncode(data));
    } catch(error){
      print('SendLocation error - $error');
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    print("🚪 Disconnected");
  }
}