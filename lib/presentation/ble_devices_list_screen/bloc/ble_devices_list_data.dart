import 'package:ble_test/data/ble_device.dart';
import 'package:equatable/equatable.dart';

final class BleDevicesListData extends Equatable {
  final List<BleDevice> devices;

  const BleDevicesListData._({required this.devices});

  factory BleDevicesListData.initial() {
    return const BleDevicesListData._(devices: []);
  }

  @override
  List<Object?> get props => [devices];

  BleDevicesListData copyWith({
    List<BleDevice>? devices,
  }) {
    return BleDevicesListData._(
      devices: devices ?? this.devices,
    );
  }
}
