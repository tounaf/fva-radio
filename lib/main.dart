import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'providers/radio_provider.dart';
import 'screens/home_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/utils/permission_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive pour le stockage local
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('favorites');
  
  // Vérifier et demander les permissions au démarrage
  await PermissionHelper.requestPermissions();
  
  // Initialiser le service audio
  await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.radio942.channel.audio',
      androidNotificationChannelName: 'Radio 94.2',
      androidNotificationIcon: 'drawable/ic_notification',
      androidShowNotificationBadge: true,
    ),
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioProvider()),
      ],
      child: MaterialApp(
        title: 'Radio 94.2',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: AppColors.darkBg,
          fontFamily: 'Poppins',
        ),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.darkBg,
        ),
        themeMode: ThemeMode.dark,
        home: HomeScreen(),
      ),
    );
  }
}

// Handler pour le service audio
class AudioPlayerHandler extends BaseAudioHandler {
  @override
  Future<void> play() async {
    // Logique de lecture
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      processingState: AudioProcessingState.ready,
    ));
  }

  @override
  Future<void> pause() async {
    // Logique de pause
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.ready,
    ));
  }

  @override
  Future<void> stop() async {
    // Logique d'arrêt
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }
}