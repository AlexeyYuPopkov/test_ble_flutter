import 'package:ble_test/common/blocking_loading_indicator.dart';
import 'package:ble_test/common/sizes.dart';
import 'package:ble_test/common/show_error_dialog_mixin.dart';
import 'package:ble_test/data/ble_device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/ble_device_bloc.dart';
import 'bloc/ble_device_data.dart';
import 'bloc/ble_device_event.dart';
import 'bloc/ble_device_state.dart';

final class BleDeviceScreen extends StatelessWidget with ShowErrorDialogMixin {
  final BleDevice device;

  const BleDeviceScreen({
    super.key,
    required this.device,
  });

  void _listener(BuildContext context, BleDeviceState state) {
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
      create: (context) => BleDeviceBloc(device: device),
      child: BlocConsumer<BleDeviceBloc, BleDeviceState>(
        buildWhen: (previous, current) {
          return true;
        },
        listener: _listener,
        builder: (context, state) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(context.pageTitle),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => _onRefresh(context),
                child: Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<BleDeviceBloc, BleDeviceState>(
                        builder: (context, state) {
                          return ListView.separated(
                            itemBuilder: (_, index) {
                              final item = state.data.items[index];
                              return Column(
                                children: [
                                  ColoredBox(
                                    color: Colors.red,
                                    child: Text(
                                      // devices.remoteId,
                                      item.str,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.blueGrey),
                                      textAlign: item.isMine
                                          ? TextAlign.right
                                          : TextAlign.left,
                                    ),
                                  ),
                                  // Text(
                                  //   '${devices.platformName}; ${devices.advName}',
                                  //   style: theme.textTheme.bodyLarge,
                                  // ),
                                ],
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(
                              height: Sizes.indent,
                            ),
                            itemCount: state.data.items.length,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 80.0,
                      child: _Form(
                        onSend: (str) => _onSend(context, str: str),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onRefresh(BuildContext context) {}

  void _onSend(BuildContext context, {required String str}) {
    context.read<BleDeviceBloc>().add(
          BleDeviceEvent.message(
            DataItem(
              isMine: true,
              str: str,
            ),
          ),
        );
  }
}

final class _Form extends StatefulWidget {
  final ValueChanged<String> onSend;
  const _Form({required this.onSend});

  @override
  State<_Form> createState() => _FormState();
}

final class _FormState extends State<_Form> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
      child: Form(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
              ),
            ),
            CupertinoButton(
              onPressed: _onSend,
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSend() {
    final str = controller.text;
    widget.onSend(str);
    controller.clear();
  }
}

// Localization
extension on BuildContext {
  String get pageTitle => 'Test BLE';
}
