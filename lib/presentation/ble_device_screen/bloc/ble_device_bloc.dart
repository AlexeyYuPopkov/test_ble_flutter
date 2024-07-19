import 'dart:async';
import 'dart:convert' as convert;

import 'package:ble_test/data/ble_consts.dart';
import 'package:ble_test/data/ble_device.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_device_data.dart';
import 'ble_device_event.dart';
import 'ble_device_state.dart';

final class BleDeviceBloc extends Bloc<BleDeviceEvent, BleDeviceState> {
  final BleDevice device;
  StreamSubscription? connectionStateSubscription;
  StreamSubscription? characteristicNotification;
  BluetoothCharacteristic? characteristic;
  // BleDeviceData get data => state.data;

  BleDeviceBloc({required this.device})
      : super(
          BleDeviceState.common(
            data: BleDeviceData.initial(),
          ),
        ) {
    _setupHandlers();

    add(const BleDeviceEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<NewMessageEvent>(_onNewMessageEvent);
  }

  @override
  Future<void> close() {
    if (device.device.isConnected) {
      device.device.disconnect();
    }

    connectionStateSubscription?.cancel();
    characteristicNotification?.cancel();
    return super.close();
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<BleDeviceState> emit,
  ) async {
    try {
      emit(BleDeviceState.loading(data: state.data));

      if (device.device.isConnected) {
        await _subscribe(device);
      } else {
        await device.device.connect();
        await _subscribe(device);
      }

      emit(
        BleDeviceState.common(data: state.data),
      );
    } catch (e) {
      emit(BleDeviceState.error(e: e, data: state.data));
    }
  }

  void _onNewMessageEvent(
    NewMessageEvent event,
    Emitter<BleDeviceState> emit,
  ) async {
    if (event.message.isMine) {
      try {
        final data = convert.utf8.encode(event.message.str).toList();
        await characteristic?.write(data, withoutResponse: false);
      } catch (e) {
        emit(
          BleDeviceState.error(data: state.data, e: e),
        );
      }
    } else {
      final newData = state.data.copyWith(
        items: [
          ...state.data.items,
          event.message,
        ],
      );

      final newState = BleDeviceState.common(data: newData);

      emit(newState);
    }
  }

  Future<void> _subscribe(BleDevice device) async {
    final service = await _discoverServices(device.device);
    if (service != null) {
      final characteristic = await _discoverCharacteristics(service);
      if (characteristic != null) {
        characteristicNotification =
            characteristic.onValueReceived.listen((data) {
          final str = convert.utf8.decode(data);
          add(BleDeviceEvent.message(DataItem(isMine: false, str: str)));
        });

        await characteristic.setNotifyValue(true);
      }
    }
  }

  Future<BluetoothService?> _discoverServices(BluetoothDevice device) async {
    if (device.isConnected) {
      final services = await device.discoverServices();

      final service = services.firstWhereOrNull(
        (e) =>
            e.serviceUuid.str128.toUpperCase() ==
            BLEConsts.serviceUuid.toUpperCase(),
      );

      return service;
    } else {
      return null;
    }
  }

  Future<BluetoothCharacteristic?> _discoverCharacteristics(
      BluetoothService service) async {
    final characteristic = service.characteristics.firstWhereOrNull(
      (e) =>
          e.characteristicUuid.str128.toUpperCase() ==
          BLEConsts.writeCharacteristicUuid.toUpperCase(),
    );
    this.characteristic = characteristic;
    return characteristic;
  }
}
