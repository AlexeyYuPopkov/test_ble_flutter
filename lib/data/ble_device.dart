import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final class BleDevice extends Equatable {
  String get remoteId => device.remoteId.str;
  String get platformName => device.platformName;
  String get advName => device.advName;

  final BluetoothDevice device;

  const BleDevice({
    required this.device,
  });

  @override
  List<Object?> get props => [remoteId];
}
