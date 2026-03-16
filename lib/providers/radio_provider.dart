import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../core/models/radio_station.dart';
import '../core/utils/permission_helper.dart';

class RadioProvider extends ChangeNotifier {
  // Constantes
  static const double DEFAULT_FREQUENCY = 94.2;
  static const double MIN_FREQUENCY = 87.5;
  static const double MAX_FREQUENCY = 108.0;
  
  // Audio player
  AudioPlayer? _audioPlayer;
  
  // État
  double _currentFrequency = DEFAULT_FREQUENCY;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _useFmRadio = false;
  bool _hasInternet = true;
  String? _errorMessage;
  
  // Stations
  List<RadioStation> _stations = [];
  List<RadioStation> _favorites = [];
  
  // Getters
  double get currentFrequency => _currentFrequency;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get useFmRadio => _useFmRadio;
  bool get hasInternet => _hasInternet;
  String? get errorMessage => _errorMessage;
  List<RadioStation> get stations => _stations;
  List<RadioStation> get favorites => _favorites;
  
  RadioStation? get currentStation {
    try {
      return _stations.firstWhere(
        (station) => station.frequency == _currentFrequency,
        orElse: () => RadioStation.defaultStation(),
      );
    } catch (e) {
      return RadioStation.defaultStation();
    }
  }
  
  // Constructeur
  RadioProvider() {
    _init();
  }
  
  // Initialisation
  Future<void> _init() async {
    await _initAudioPlayer();
    await _loadStations();
    await _checkRadioMode();
    _monitorConnectivity();
  }
  
  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    
    // Écouter les changements d'état
    _audioPlayer!.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading;
      notifyListeners();
    });
    
    // Écouter les erreurs
    _audioPlayer!.playbackEventStream.listen((event) {},
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    );
  }
  
  Future<void> _loadStations() async {
    // Charger les stations depuis Hive ou une source de données
    _stations = [
      RadioStation.defaultStation(),
      RadioStation(
        id: '2',
        name: 'Nostalgie',
        frequency: 95.6,
        logoUrl: 'assets/logos/nostalgie.png',
        streamUrl: 'https://stream.nostalgie.fr/nostalgie',
        genre: 'Variété française',
      ),
      RadioStation(
        id: '3',
        name: 'RTL',
        frequency: 104.3,
        logoUrl: 'assets/logos/rtl.png',
        streamUrl: 'https://stream.rtl.fr/rtl',
        genre: 'Information',
      ),
      RadioStation(
        id: '4',
        name: 'Skyrock',
        frequency: 96.5,
        logoUrl: 'assets/logos/skyrock.png',
        streamUrl: 'https://stream.skyrock.fr/skyrock',
        genre: 'Hip-Hop / Rap',
      ),
    ];
    
    // Charger les favoris
    var favBox = await Hive.openBox('favorites');
    _favorites = favBox.get('favorites', defaultValue: []);
    
    notifyListeners();
  }
  
  Future<void> _checkRadioMode() async {
    bool hasFm = await PermissionHelper.hasFmReceiver();
    bool headphones = await PermissionHelper.areHeadphonesPlugged();
    _hasInternet = await PermissionHelper.hasInternetConnection();
    
    // Utiliser la FM si disponible et si pas d'internet
    _useFmRadio = hasFm && headphones && !_hasInternet;
    
    notifyListeners();
  }
  
  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      _hasInternet = result != ConnectivityResult.none;
      
      // Si on perd internet et qu'on est en streaming, essayer de passer en FM
      if (!_hasInternet && !_useFmRadio) {
        _checkRadioMode();
      }
      
      notifyListeners();
    });
  }
  
  // Changer de fréquence
  Future<void> setFrequency(double frequency) async {
    if (frequency < MIN_FREQUENCY || frequency > MAX_FREQUENCY) return;
    
    _currentFrequency = double.parse(frequency.toStringAsFixed(1));
    
    // Si on joue, changer de station
    if (_isPlaying) {
      await play();
    }
    
    notifyListeners();
  }
  
  // Jouer/Pause
  Future<void> play() async {
    if (_useFmRadio) {
      // Mode FM - pas besoin de stream
      _isPlaying = true;
      notifyListeners();
    } else {
      // Mode streaming
      if (!_hasInternet) {
        _errorMessage = 'Pas de connexion internet';
        notifyListeners();
        return;
      }
      
      try {
        await _audioPlayer?.setUrl(currentStation!.streamUrl);
        await _audioPlayer?.play();
      } catch (e) {
        _errorMessage = 'Erreur de lecture: $e';
        notifyListeners();
      }
    }
  }
  
  Future<void> pause() async {
    if (_useFmRadio) {
      _isPlaying = false;
      notifyListeners();
    } else {
      await _audioPlayer?.pause();
    }
  }
  
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }
  
  // Scanner automatique
  Future<void> startScan() async {
    _isLoading = true;
    notifyListeners();
    
    for (double freq = MIN_FREQUENCY; 
         freq <= MAX_FREQUENCY; 
         freq += 0.1) {
      await Future.delayed(Duration(milliseconds: 50));
      _currentFrequency = double.parse(freq.toStringAsFixed(1));
      notifyListeners();
    }
    
    // Revenir à 94.2
    _currentFrequency = DEFAULT_FREQUENCY;
    _isLoading = false;
    notifyListeners();
  }
  
  // Ajouter aux favoris
  Future<void> toggleFavorite(RadioStation station) async {
    if (_favorites.contains(station)) {
      _favorites.remove(station);
    } else {
      _favorites.add(station);
    }
    
    var favBox = await Hive.openBox('favorites');
    await favBox.put('favorites', _favorites);
    
    notifyListeners();
  }
  
  // Nettoyage
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}