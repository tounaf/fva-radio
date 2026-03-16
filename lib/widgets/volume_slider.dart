import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../core/constants/app_colors.dart';

class VolumeSlider extends StatefulWidget {
  @override
  _VolumeSliderState createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _volume = 0.7;
  bool _isMuted = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glassBlack,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Bouton mute
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_down,
              color: _isMuted ? Colors.red : Colors.white70,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
                if (_isMuted) {
                  AudioPlayer().setVolume(0);
                } else {
                  AudioPlayer().setVolume(_volume);
                }
              });
            },
          ),
          
          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: _volume,
                min: 0,
                max: 1,
                activeColor: AppColors.primary,
                inactiveColor: Colors.white24,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                    _isMuted = false;
                    AudioPlayer().setVolume(_volume);
                  });
                },
              ),
            ),
          ),
          
          // Volume max
          IconButton(
            icon: Icon(
              Icons.volume_up,
              color: Colors.white70,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _volume = 1.0;
                _isMuted = false;
                AudioPlayer().setVolume(1.0);
              });
            },
          ),
        ],
      ),
    );
  }
}