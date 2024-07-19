import 'package:equatable/equatable.dart';

final class BleDeviceData extends Equatable {
  final List<DataItem> items;

  const BleDeviceData._({
    required this.items,
  });

  factory BleDeviceData.initial() {
    return const BleDeviceData._(
      items: [],
    );
  }

  @override
  List<Object?> get props => [items];

  BleDeviceData copyWith({
    List<DataItem>? items,
  }) {
    // debugger();
    return BleDeviceData._(
      items: items ?? this.items,
    );
  }
}

final class DataItem extends Equatable {
  final bool isMine;
  final String str;

  const DataItem({required this.isMine, required this.str});

  @override
  List<Object?> get props => [isMine, str];
}
