import 'package:ble_test/common/blocking_loading_indicator.dart';
import 'package:ble_test/common/sizes.dart';
import 'package:ble_test/common/show_error_dialog_mixin.dart';
import 'package:ble_test/data/ble_device.dart';
import 'package:ble_test/presentation/ble_device_screen/ble_device_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/ble_devices_list_bloc.dart';
import 'bloc/ble_devices_list_event.dart';
import 'bloc/ble_devices_list_state.dart';

final class BleDevicesListScreen extends StatelessWidget
    with ShowErrorDialogMixin {
  const BleDevicesListScreen({super.key});

  void _listener(BuildContext context, BleDevicesListState state) {
    BlockingLoadingIndicator.of(context).isLoading = state is LoadingState;

    switch (state) {
      case LoadingState():
      case CommonState():
        break;
      case ErrorState(e: final e):
        showError(context, e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BleDevicesListBloc(),
      child: BlocConsumer<BleDevicesListBloc, BleDevicesListState>(
        listener: _listener,
        builder: (context, state) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(context.pageTitle),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        CupertinoButton(
                          child: SizedBox(
                            width: 100.0,
                            child: Text(
                              'Adv',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          onPressed: () => _onAdv(context),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          child: SizedBox(
                            width: 100.0,
                            child: Text(
                              'Scan',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          onPressed: () => _onScan(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (_, index) {
                        return _ListItem(
                          device: state.data.devices[index],
                          onTap: (e) => _onDevice(context, device: e),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(
                        height: Sizes.indent,
                      ),
                      itemCount: state.data.devices.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onDevice(
    BuildContext context, {
    required BleDevice device,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BleDeviceScreen(
          device: device,
        ),
      ),
    );
  }

  void _onAdv(BuildContext context) => context.read<BleDevicesListBloc>().add(
        const BleDevicesListEvent.adv(),
      );

  void _onScan(BuildContext context) => context.read<BleDevicesListBloc>().add(
        const BleDevicesListEvent.scan(),
      );
}

final class _ListItem extends StatelessWidget {
  final BleDevice device;
  final ValueChanged<BleDevice> onTap;

  const _ListItem({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      onPressed: () => onTap(device),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  device.remoteId,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.blueGrey),
                ),
                Text(
                  '${device.platformName}; ${device.advName}',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: Sizes.indent4x,
            child: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}

// Localization
extension on BuildContext {
  String get pageTitle => 'Test BLE';
}
