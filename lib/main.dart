import 'package:ble_test/common/blocking_loading_indicator.dart';
import 'package:ble_test/presentation/ble_devices_list_screen/ble_devices_list_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlockingLoadingIndicator(
        child: const BleDevicesListScreen(),
      ),
    );
  }
}
