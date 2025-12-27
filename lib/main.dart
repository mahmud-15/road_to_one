import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'main.dart' as GetStorage;
import 'services/notification/notification_service.dart';
import 'services/socket/socket_service.dart';
import 'services/storage/storage_services.dart';
import 'features/store/data/models/cart_item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(CartItemAdapter.typeIdValue)) {
    Hive.registerAdapter(CartItemAdapter());
  }
  await Hive.openBox<CartItem>(CartItemAdapter.boxName);

  /// 🔹 Make top (status bar) white text globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,              // top status bar background
      statusBarIconBrightness: Brightness.dark,  // top icons black
      systemNavigationBarColor: Colors.black,           // 🔥 BOTTOM navbar black
      systemNavigationBarIconBrightness: Brightness.light, // icons white
    ),
  );

  await init();

  runApp(const MyApp());
}

init() async {
  DependencyInjection dI = DependencyInjection();
  dI.dependencies();
  SocketServices.connectToSocket();

  await Future.wait([
    LocalStorage.getAllPrefData(),
    NotificationService.initLocalNotification(),
  ]);
}