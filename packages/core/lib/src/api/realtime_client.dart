import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeEvent {
  final String type;
  final dynamic payload;
  final DateTime ts;

  const RealtimeEvent({required this.type, required this.payload, required this.ts});

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) => RealtimeEvent(
        type: json['type'] as String,
        payload: json['payload'],
        ts: json['ts'] != null ? DateTime.tryParse(json['ts'] as String) ?? DateTime.now() : DateTime.now(),
      );
}

/// Synthetic, client-only event types the UI can listen for alongside real
/// server broadcasts, so a screen can show "Reconnecting…" during a network
/// blip instead of silently going stale (spec section 35: never leave the
/// user guessing during poor network).
class RealtimeStatus {
  static const connected = '_status.connected';
  static const disconnected = '_status.disconnected';
  static const reconnecting = '_status.reconnecting';
}

/// WebSocket client with automatic exponential-backoff reconnect. All three
/// apps share one of these pointed at `backend/local-server`'s /ws endpoint.
class RealtimeClient {
  final String wsUrl;
  final _controller = StreamController<RealtimeEvent>.broadcast();
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _retryTimer;
  bool _disposed = false;
  int _retryDelayMs = 1000;
  static const _maxRetryDelayMs = 15000;

  RealtimeClient(this.wsUrl);

  Stream<RealtimeEvent> get events => _controller.stream;

  void connect() {
    if (_disposed) return;
    _retryTimer?.cancel();
    try {
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel = channel;
      _sub = channel.stream.listen(
        (raw) {
          _retryDelayMs = 1000;
          final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
          final event = RealtimeEvent.fromJson(decoded);
          if (event.type == 'connection.ack') {
            _emit(RealtimeStatus.connected, {});
            return;
          }
          _controller.add(event);
        },
        onError: (_) => _scheduleReconnect(),
        onDone: () => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _emit(RealtimeStatus.reconnecting, {});
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(milliseconds: _retryDelayMs), connect);
    _retryDelayMs = (_retryDelayMs * 2).clamp(1000, _maxRetryDelayMs);
  }

  void _emit(String type, dynamic payload) {
    if (!_controller.isClosed) _controller.add(RealtimeEvent(type: type, payload: payload, ts: DateTime.now()));
  }

  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _controller.close();
  }
}
