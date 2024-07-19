import 'package:ble_test/data/ble_device.dart';
import 'package:equatable/equatable.dart';

sealed class BleDevicesListEvent extends Equatable {
  const BleDevicesListEvent();

  // const factory BleDevicesListEvent.initial() = InitialEvent;

  const factory BleDevicesListEvent.adv() = AdvEvent;

  const factory BleDevicesListEvent.scan() = ScanEvent;

  const factory BleDevicesListEvent.newDevices({
    required List<BleDevice> devices,
  }) = NewDevicesEvent;

  @override
  List<Object?> get props => const [];
}

// final class InitialEvent extends BleDevicesListEvent {
//   const InitialEvent();
// }

final class AdvEvent extends BleDevicesListEvent {
  const AdvEvent();
}

final class ScanEvent extends BleDevicesListEvent {
  const ScanEvent();
}

final class NewDevicesEvent extends BleDevicesListEvent {
  final List<BleDevice> devices;
  const NewDevicesEvent({required this.devices});
}
