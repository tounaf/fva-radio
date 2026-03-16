import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../core/constants/app_colors.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onScan;
  
  const PlayerControls({
    Key? key,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onScan,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton scan
          _buildControlButton(
            icon: Icons.search,
            onPressed: onScan,
            label: 'Scan',
          ),
          
          // Bouton précédent
          _buildControlButton(
            icon: Icons.skip_previous,
            onPressed: onPrevious,
            size: 40,
          ),
          
          // Bouton play/pause
          OpenContainer(
            closedColor: Colors.transparent,
            closedElevation: 0,
            openColor: Colors.transparent,
            middleColor: Colors.transparent,
            closedShape: CircleBorder(),
            closedBuilder: (context, action) {
              return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: isLoading
                      ? SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                  onPressed: onPlayPause,
                ),
              );
            },
            openBuilder: (context, action) {
              return Container(); // Animation container
            },
          ),
          
          // Bouton suivant
          _buildControlButton(
            icon: Icons.skip_next,
            onPressed: onNext,
            size: 40,
          ),
          
          // Bouton favoris (espace vide pour symétrie)
          _buildControlButton(
            icon: Icons.favorite_border,
            onPressed: () {},
            label: '',
            enabled: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 30,
    String label = '',
    bool enabled = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: enabled ? Colors.white70 : Colors.white24,
            size: size,
          ),
          onPressed: enabled ? onPressed : null,
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}