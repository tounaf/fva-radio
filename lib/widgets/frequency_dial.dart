import 'package:flutter/material.dart';
import 'dart:math';
import '../core/constants/app_colors.dart';

class FrequencyDial extends StatefulWidget {
  final double initialFrequency;
  final Function(double) onFrequencyChanged;
  
  const FrequencyDial({
    Key? key,
    required this.initialFrequency,
    required this.onFrequencyChanged,
  }) : super(key: key);
  
  @override
  _FrequencyDialState createState() => _FrequencyDialState();
}

class _FrequencyDialState extends State<FrequencyDial>
    with SingleTickerProviderStateMixin {
  
  late double _currentFrequency;
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    _currentFrequency = widget.initialFrequency;
    
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Calculer l'angle basé sur la fréquence
    // Bande FM: 87.5 à 108.0 MHz
    double minFreq = 87.5;
    double maxFreq = 108.0;
    double angleRange = 300 * (pi / 180); // 300 degrés en radians
    double startAngle = -150 * (pi / 180); // -150 degrés
    
    double t = (_currentFrequency - minFreq) / (maxFreq - minFreq);
    double angle = startAngle + (t * angleRange);
    
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.darkSurface,
              AppColors.darkBg,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _currentFrequency == 94.2
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.black26,
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CustomPaint(
          painter: FrequencyPainter(
            frequency: _currentFrequency,
            specialMarker: 94.2,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkCard,
                      border: Border.all(
                        color: _currentFrequency == 94.2
                            ? AppColors.primary
                            : Colors.white24,
                        width: _currentFrequency == 94.2 ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _currentFrequency == 94.2
                              ? AppColors.primary.withOpacity(0.5)
                              : Colors.transparent,
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.radio,
                      color: _currentFrequency == 94.2
                          ? AppColors.primary
                          : Colors.white54,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    // Logique simple pour changer la fréquence basée sur le mouvement vertical
    double delta = details.delta.dy * -0.1; // Inverser pour que haut = +, bas = -
    
    setState(() {
      _currentFrequency += delta;
      _currentFrequency = _currentFrequency.clamp(87.5, 108.0);
      _currentFrequency = double.parse(_currentFrequency.toStringAsFixed(1));
      
      // Notifier le changement
      widget.onFrequencyChanged(_currentFrequency);
    });
    
    // Animation de rotation
    _rotationController.forward(from: 0);
  }
}

class FrequencyPainter extends CustomPainter {
  final double frequency;
  final double specialMarker;
  
  FrequencyPainter({
    required this.frequency,
    required this.specialMarker,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2 - 10;
    
    Paint tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;
    
    Paint specialPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3;
    
    // Dessiner les graduations
    for (int i = 0; i < 100; i++) {
      double angle = (i * 3.0) * pi / 180;
      double startX = centerX + (radius - 20) * cos(angle - pi / 2);
      double startY = centerY + (radius - 20) * sin(angle - pi / 2);
      double endX = centerX + radius * cos(angle - pi / 2);
      double endY = centerY + radius * sin(angle - pi / 2);
      
      // Marquer spécialement 94.2
      if ((i * 0.2 + 87.5 - 94.2).abs() < 0.1) {
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), specialPaint);
      } else {
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}