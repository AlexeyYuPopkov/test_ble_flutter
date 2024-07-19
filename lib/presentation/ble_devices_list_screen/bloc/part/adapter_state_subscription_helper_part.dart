part of '../ble_devices_list_bloc.dart';

mixin AdapterStateSubscriptionHelper {
  StreamSubscription createAdapterStateSubscriptions() {
    return FlutterBluePlus.adapterState.listen((e) {
      String message = '';
      switch (e) {
        case BluetoothAdapterState.unknown:
          message = 'BluetoothAdapterState: unknown';
          break;
        case BluetoothAdapterState.unavailable:
          message = 'BluetoothAdapterState: unavailable';
          break;
        case BluetoothAdapterState.unauthorized:
          message = 'BluetoothAdapterState: unauthorized';
          break;
        case BluetoothAdapterState.turningOn:
          message = 'BluetoothAdapterState: turningOn';
          break;
        case BluetoothAdapterState.on:
          break;
        case BluetoothAdapterState.turningOff:
          message = 'BluetoothAdapterState: turningOff';
          break;
        case BluetoothAdapterState.off:
          message = 'BluetoothAdapterState: off';
          break;
      }

      if (message.isNotEmpty) {
        if (kDebugMode) {
          print('BluetoothAdapterState: $message');
          debugger();
        }
      }
    });
  }
}
