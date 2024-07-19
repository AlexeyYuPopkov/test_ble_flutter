import 'package:equatable/equatable.dart';

import 'ble_devices_list_data.dart';

sealed class BleDevicesListState extends Equatable {
  final BleDevicesListData data;

  const BleDevicesListState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory BleDevicesListState.common({
    required BleDevicesListData data,
  }) = CommonState;

  const factory BleDevicesListState.loading({
    required BleDevicesListData data,
  }) = LoadingState;

  const factory BleDevicesListState.error({
    required BleDevicesListData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends BleDevicesListState {
  const CommonState({required super.data});
}

final class LoadingState extends BleDevicesListState {
  const LoadingState({required super.data});
}

final class ErrorState extends BleDevicesListState {
  final Object e;
  const ErrorState({
    required super.data,
    required this.e,
  });
}
