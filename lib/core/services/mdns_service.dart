import 'dart:async';
import 'package:bonsoir/bonsoir.dart';

/// Service for discovering SalitaKo backend via mDNS
class MdnsService {
  static const String _serviceType = '_salitako._tcp';
  
  BonsoirDiscovery? _discovery;
  StreamSubscription? _subscription;
  
  String? _discoveredHost;
  int? _discoveredPort;
  bool _isDiscovering = false;
  
  /// Callback when server is found
  Function(String host, int port)? onServerFound;
  
  /// Callback when server is lost
  Function()? onServerLost;
  
  String? get discoveredHost => _discoveredHost;
  int? get discoveredPort => _discoveredPort;
  bool get isDiscovering => _isDiscovering;
  
  /// Get the full base URL of the discovered server
  String? get baseUrl {
    if (_discoveredHost != null && _discoveredPort != null) {
      return 'http://$_discoveredHost:$_discoveredPort';
    }
    return null;
  }
  
  /// Start discovering SalitaKo servers on the network
  Future<void> startDiscovery() async {
    if (_isDiscovering) return;
    
    _isDiscovering = true;
    print('🔍 Starting mDNS discovery for $_serviceType...');
    
    try {
      _discovery = BonsoirDiscovery(type: _serviceType);
      await _discovery!.ready;
      
      _subscription = _discovery!.eventStream?.listen((event) {
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
          print('📡 Service found: ${event.service?.name}');
          // Need to resolve to get the IP
          event.service?.resolve(_discovery!.serviceResolver);
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
          final service = event.service as ResolvedBonsoirService;
          _discoveredHost = service.host;
          _discoveredPort = service.port;
          
          print('✅ SalitaKo server discovered: $_discoveredHost:$_discoveredPort');
          
          // Print service attributes if available
          if (service.attributes.isNotEmpty) {
            print('📋 Service info: ${service.attributes}');
          }
          
          onServerFound?.call(_discoveredHost!, _discoveredPort!);
        } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
          print('❌ Service lost: ${event.service?.name}');
          if (_discoveredHost == event.service?.name) {
            _discoveredHost = null;
            _discoveredPort = null;
            onServerLost?.call();
          }
        }
      });
      
      await _discovery!.start();
    } catch (e) {
      print('⚠️ mDNS discovery failed: $e');
      _isDiscovering = false;
    }
  }
  
  /// Stop discovery
  Future<void> stopDiscovery() async {
    _isDiscovering = false;
    await _subscription?.cancel();
    await _discovery?.stop();
    _discovery = null;
    _subscription = null;
  }
  
  /// Wait for server discovery with timeout
  Future<bool> waitForServer({Duration timeout = const Duration(seconds: 5)}) async {
    if (_discoveredHost != null) return true;
    
    final completer = Completer<bool>();
    Timer? timer;
    
    final previousCallback = onServerFound;
    onServerFound = (host, port) {
      timer?.cancel();
      if (!completer.isCompleted) {
        completer.complete(true);
      }
      previousCallback?.call(host, port);
    };
    
    timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });
    
    if (!_isDiscovering) {
      await startDiscovery();
    }
    
    return completer.future;
  }
  
  void dispose() {
    stopDiscovery();
  }
}
