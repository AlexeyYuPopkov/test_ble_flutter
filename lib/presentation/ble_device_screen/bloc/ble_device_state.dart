import 'package:equatable/equatable.dart';

import 'ble_device_data.dart';

sealed class BleDeviceState extends Equatable {
  final BleDeviceData data;

  const BleDeviceState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory BleDeviceState.common({
    required BleDeviceData data,
  }) = CommonState;

  const factory BleDeviceState.loading({
    required BleDeviceData data,
  }) = LoadingState;

  const factory BleDeviceState.error({
    required BleDeviceData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends BleDeviceState {
  const CommonState({required super.data});

  // @override
  // bool operator ==(Object other) => false;

  // @override
  // // ignore: unnecessary_overrides
  // int get hashCode => super.hashCode;
}

final class LoadingState extends BleDeviceState {
  const LoadingState({required super.data});
}

final class ErrorState extends BleDeviceState {
  final Object e;
  const ErrorState({
    required super.data,
    required this.e,
  });
}
