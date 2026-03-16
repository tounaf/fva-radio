import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/models/radio_station.dart';

class StationInfo extends StatelessWidget {
  final RadioStation? station;
  final bool isDefault;
  
  const StationInfo({
    Key? key,
    this.station,
    this.isDefault = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (station == null) return SizedBox.shrink();
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDefault 
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.glassBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault 
              ? AppColors.primary 
              : Colors.white10,
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Logo de la station avec animation
          Hero(
            tag: 'station_logo_${station!.id}',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkCard,
                image: DecorationImage(
                  image: AssetImage(station!.logoUrl),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: isDefault ? AppColors.primary : Colors.white30,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDefault 
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.transparent,
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Nom de la station
          Text(
            station!.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          
          SizedBox(height: 4),
          
          // Fréquence
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${station!.frequency.toStringAsFixed(1)} MHz',
              style: TextStyle(
                fontSize: 18,
                color: isDefault ? AppColors.primary : Colors.white70,
                fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          
          SizedBox(height: 8),
          
          // Genre
          Text(
            station!.genre,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          
          // Description (si disponible)
          if (station!.description.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              station!.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          // Badge "Station recommandée" pour 94.2
          if (isDefault) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stars,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Station recommandée 94.2 FM',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}