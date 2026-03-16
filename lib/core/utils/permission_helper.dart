import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionHelper {
  // Vérifier et demander toutes les permissions nécessaires
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      return await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      return await _requestIOSPermissions();
    }
    return true;
  }

  static Future<bool> _requestAndroidPermissions() async {
    List<Permission> permissions = [
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
      Permission.accessNotificationPolicy,
    ];

    // Vérifier la version d'Android pour les permissions spécifiques
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    
    // Android 13+ (API 33+) nécessite des permissions supplémentaires
    if (androidInfo.version.sdkInt >= 33) {
      permissions.add(Permission.nearbyWifiDevices);
    }

    // Demander les permissions une par une
    for (var permission in permissions) {
      PermissionStatus status = await permission.status;
      
      if (status.isDenied) {
        status = await permission.request();
      }
      
      if (status.isPermanentlyDenied) {
        // Ouvrir les paramètres si l'utilisateur a refusé définitivement
        await openAppSettings();
        return false;
      }
    }

    return true;
  }

  static Future<bool> _requestIOSPermissions() async {
    // iOS a moins de permissions à demander
    return true;
  }

  // Vérifier si le téléphone a un récepteur FM
  static Future<bool> hasFmReceiver() async {
    if (Platform.isAndroid) {
      // Sur Android, la plupart des téléphones ont un récepteur FM
      // mais il est souvent désactivé logiciellement
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      
      // Exclure certains modèles sans FM
      List<String> noFmModels = ['Pixel', 'iPhone'];
      for (var model in noFmModels) {
        if (androidInfo.model.contains(model)) {
          return false;
        }
      }
      
      return true;
    }
    return false; // iOS n'a jamais de FM
  }

  // Vérifier si des écouteurs sont branchés (nécessaires pour la FM)
  static Future<bool> areHeadphonesPlugged() async {
    // Cette fonction nécessite un plugin spécifique
    // Pour l'instant, on retourne true pour simplifier
    return true;
  }

  // Vérifier la connexion internet
  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Afficher une boîte de dialogue pour les permissions
  static Future<void> showPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions requises'),
        content: Text(
          'Pour une expérience optimale, Radio 94.2 a besoin de :\n\n'
          '• 📡 Accès réseau (streaming)\n'
          '• 🔔 Notifications (contrôle lecture)\n'
          '• 🔋 Optimisation batterie (lecture continue)\n\n'
          'Ces permissions sont optionnelles mais recommandées.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () async {
              await requestPermissions();
              Navigator.pop(context);
            },
            child: Text('Autoriser'),
          ),
        ],
      ),
    );
  }
}