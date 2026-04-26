import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network bağlantı durumu servisi
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isConnected = true;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  /// Bağlantı durumu stream'i
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Mevcut bağlantı durumu
  bool get isConnected => _isConnected;

  /// Mevcut bağlantı türü
  ConnectivityResult get connectionStatus => _connectionStatus;

  /// Servisi başlat
  Future<void> initialize() async {
    try {
      // İlk bağlantı durumunu kontrol et
      final result = await _connectivity.checkConnectivity();
      _connectionStatus = result;
      _updateConnectionStatus(_connectionStatus);

      // Bağlantı değişikliklerini dinle
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (result) {
          _updateConnectionStatus(result);
        },
        onError: (error) {
          debugPrint('ConnectivityService error: $error');
        },
      );
    } catch (e) {
      debugPrint('ConnectivityService.initialize error: $e');
    }
  }

  /// Bağlantı durumunu güncelle
  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus = result;

    // Bağlantı var mı kontrol et
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    // Durum değiştiyse bildir
    if (wasConnected != _isConnected) {
      _connectionController.add(_isConnected);
      debugPrint(
        'ConnectivityService: Connection ${_isConnected ? 'restored' : 'lost'}',
      );
    }
  }

  /// Bağlantı türü açıklaması
  String getConnectionTypeDescription() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobil veri';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Diğer';
      case ConnectivityResult.none:
        return 'Bağlantı yok';
    }
  }

  /// Bağlantı hızını test et (basit ping testi)
  Future<bool> testConnection({
    String host = 'google.com',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final result = await InternetAddress.lookup(host).timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('ConnectivityService.testConnection error: $e');
      return false;
    }
  }

  /// Servisi temizle
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}
