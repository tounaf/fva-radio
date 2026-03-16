import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FrequencyDisplay extends StatelessWidget {
  final double frequency;
  final bool isHighlighted;
  
  const FrequencyDisplay({
    Key? key,
    required this.frequency,
    this.isHighlighted = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    String freqStr = frequency.toStringAsFixed(1);
    List<String> parts = freqStr.split('.');
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.glassBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted 
              ? AppColors.primary 
              : Colors.white24,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Partie entière
          Text(
            parts[0],
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: isHighlighted 
                  ? AppColors.primary 
                  : Colors.white,
              shadows: isHighlighted ? [
                Shadow(
                  color: AppColors.primary,
                  offset: Offset(0, 0),
                  blurRadius: 20,
                ),
              ] : null,
            ),
          ),
          // Point décimal
          Text(
            '.',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: isHighlighted 
                  ? AppColors.primary 
                  : Colors.white70,
            ),
          ),
          // Partie décimale
          Text(
            parts[1],
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isHighlighted 
                  ? AppColors.primary.withOpacity(0.8)
                  : Colors.white70,
            ),
          ),
          SizedBox(width: 8),
          // Unité
          Text(
            'MHz',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white54,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}