import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:ble_test/common/errors/app_error.dart';
import 'package:ble_test/data/ble_consts.dart';
import 'package:ble_test/data/ble_device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

import 'ble_devices_list_data.dart';
import 'ble_devices_list_event.dart';
import 'ble_devices_list_state.dart';

part 'part/adapter_state_subscription_helper_part.dart';

final class BleDevicesListBloc
    extends Bloc<BleDevicesListEvent, BleDevicesListState>
    with BLEConstsHelper, AdapterStateSubscriptionHelper {
  BleDevicesListData get data => state.data;

  StreamSubscription? scanDevicesSubscription;
  StreamSubscription? adapterStateSubscription;

  BleDevicesListBloc()
      : super(
          BleDevicesListState.common(
            data: BleDevicesListData.initial(),
          ),
        ) {
    _setupSubscriptions();
    adapterStateSubscription = createAdapterStateSubscriptions();
    _setupHandlers();

    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }

  @override
  Future<void> close() {
    scanDevicesSubscription?.cancel();
    adapterStateSubscription?.cancel();
    return super.close();
  }

  void _setupHandlers() {
    // on<InitialEvent>(_onInitialEvent);
    on<AdvEvent>(_onAdvEvent);
    on<ScanEvent>(_onScanEvent);
    on<NewDevicesEvent>(_onNewDevicesEvent);
  }

  void _setupSubscriptions() {
    scanDevicesSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        add(
          BleDevicesListEvent.newDevices(
            devices: [
              for (final result in results)
                BleDevice(
                  device: result.device,
                )
            ],
          ),
        );
      },
    );
  }

  void _onAdvEvent(
    AdvEvent event,
    Emitter<BleDevicesListState> emit,
  ) async {
    try {
      await _startAdvertising(BLEConsts.scanDuration);

      emit(
        BleDevicesListState.common(data: data),
      );
    } catch (e) {
      emit(BleDevicesListState.error(e: e, data: data));
    }
  }

  void _onScanEvent(
    ScanEvent event,
    Emitter<BleDevicesListState> emit,
  ) async {
    try {
      _startScan(BLEConsts.scanDuration);

      emit(
        BleDevicesListState.common(data: data),
      );
    } catch (e) {
      emit(BleDevicesListState.error(e: e, data: data));
    }
  }

  void _onNewDevicesEvent(
    NewDevicesEvent event,
    Emitter<BleDevicesListState> emit,
  ) {
    emit(
      BleDevicesListState.common(data: data.copyWith(devices: event.devices)),
    );
  }
}

sealed class BleError extends AppError {
  const BleError({required super.message, super.reason, super.parentError});
}

final class NotSupportedByDevice extends BleError {
  const NotSupportedByDevice({super.reason, super.parentError})
      : super(message: 'Bluetooth not supported by this device');
}

final class BluetoothAdapterStateError extends BleError {
  const BluetoothAdapterStateError({required super.message})
      : super(reason: message, parentError: null);
}

mixin BLEConstsHelper {
  Future<void> _startScan(Duration timeout) async {
    FlutterBluePlus.startScan(
      timeout: timeout,
      withNames: const [
        BLEConsts.advertisementName,
      ],
      withServices: [Guid.fromString(BLEConsts.serviceUuid)],
    );
  }

  Future<void> _startAdvertising(Duration timeout) async {
    // await Future.delayed(Duration(seconds: 3));
    const platform = MethodChannel('com.popkov.test.bleTest/advertise');
    if (Platform.isIOS) {
      try {
        await platform.invokeMethod('stopAdvertising');
        await platform.invokeMethod('startAdvertising');
        // await Future.delayed(timeout);
        // await platform.invokeMethod('stopAdvertising');
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print("Failed to start advertising: '${e.message}'.");
        }
      }
    }
  }
}
