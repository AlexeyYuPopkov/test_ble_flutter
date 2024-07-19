import 'package:equatable/equatable.dart';

import 'ble_device_data.dart';

sealed class BleDeviceEvent extends Equatable {
  const BleDeviceEvent();

  const factory BleDeviceEvent.initial() = InitialEvent;

  const factory BleDeviceEvent.message(DataItem message) = NewMessageEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends BleDeviceEvent {
  const InitialEvent();
}

final class NewMessageEvent extends BleDeviceEvent {
  final DataItem message;
  const NewMessageEvent(this.message);
}
