import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class BleDevice {
  final BluetoothDevice device;
  final String name;
  BleDevice(this.device, this.name);
}

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  final List<BleDevice> _foundDevices = [];
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _characteristicSubscription;
  
  Function(List<BleDevice>)? onDevicesFound;
  Function(int)? onHeartRateUpdate;

  // Heart Rate Service UUID
  final Guid _hrServiceUuid = Guid("180D");
  // Heart Rate Measurement Characteristic UUID
  final Guid _hrCharUuid = Guid("2A37");

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status == PermissionStatus.granted);
  }

  void startScan() async {
    if (!await requestPermissions()) {
      debugPrint("BLE Permissions not granted");
      return;
    }

    _foundDevices.clear();
    onDevicesFound?.call(_foundDevices);

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.advName.isNotEmpty) {
            bool exists = _foundDevices.any((d) => d.device.remoteId == r.device.remoteId);
            if (!exists) {
              _foundDevices.add(BleDevice(r.device, r.device.advName));
              onDevicesFound?.call(_foundDevices);
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Error starting scan: $e");
    }
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      stopScan();
      await device.connect();
      _connectedDevice = device;
      
      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid == _hrServiceUuid) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid == _hrCharUuid) {
              await characteristic.setNotifyValue(true);
              _characteristicSubscription = characteristic.onValueReceived.listen((value) {
                if (value.isNotEmpty) {
                  // Standard GATT HR Profile parser
                  int flag = value[0];
                  int hrValue = 0;
                  if ((flag & 0x01) != 0) {
                    // 16-bit format
                    if (value.length >= 3) hrValue = (value[2] << 8) + value[1];
                  } else {
                    // 8-bit format
                    if (value.length >= 2) hrValue = value[1];
                  }
                  if (hrValue > 0) {
                    onHeartRateUpdate?.call(hrValue);
                  }
                }
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Connection error: $e");
    }
  }

  void disconnect() {
    _characteristicSubscription?.cancel();
    _connectedDevice?.disconnect();
    _connectedDevice = null;
  }
  
  // HACKATHON BONUS: Simulate device connection if no real device is available
  Timer? _simulationTimer;
  void simulateDeviceConnection() {
    stopScan();
    disconnect();
    
    // Simulate heart rate varying between 72 and 78
    int currentHr = 75;
    bool up = true;
    
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (up) {
        currentHr += 1;
        if (currentHr >= 78) up = false;
      } else {
        currentHr -= 1;
        if (currentHr <= 72) up = true;
      }
      onHeartRateUpdate?.call(currentHr);
    });
  }
  
  void stopSimulation() {
    _simulationTimer?.cancel();
  }
}
