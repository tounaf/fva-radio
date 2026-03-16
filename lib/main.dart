import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/radio_provider.dart';
import '../widgets/frequency_dial.dart';
import '../widgets/frequency_display.dart';
import '../widgets/player_controls.dart';
import '../widgets/station_info.dart';
import '../widgets/volume_slider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/permission_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    
    // Vérifier les permissions au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }
  
  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        PermissionHelper.showPermissionDialog(context);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<RadioProvider>(
            builder: (context, provider, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildAppBar(provider),
                    
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Mode indicator
                              _buildModeIndicator(provider),
                              
                              SizedBox(height: 10),
                              
                              // Frequency display
                              FrequencyDisplay(
                                frequency: provider.currentFrequency,
                                isHighlighted: provider.currentFrequency == 94.2,
                              ),
                              
                              SizedBox(height: 10),
                              
                              // Frequency dial
                              FrequencyDial(
                                initialFrequency: provider.currentFrequency,
                                onFrequencyChanged: (freq) {
                                  provider.setFrequency(freq);
                                },
                              ),
                              
                              SizedBox(height: 20),
                              
                              // Station info
                              StationInfo(
                                station: provider.currentStation,
                                isDefault: provider.currentFrequency == 94.2,
                              ),
                              
                              SizedBox(height: 20),
                              
                              // Player controls
                              PlayerControls(
                                isPlaying: provider.isPlaying,
                                isLoading: provider.isLoading,
                                onPlayPause: () => provider.togglePlayPause(),
                                onNext: () => _changeFrequency(provider, 0.1),
                                onPrevious: () => _changeFrequency(provider, -0.1),
                                onScan: () => provider.startScan(),
                              ),
                              
                              SizedBox(height: 20),
                              
                              // Volume slider
                              VolumeSlider(),
                              
                              SizedBox(height: 20),
                              
                              // Quick return button for 94.2
                              if (provider.currentFrequency != 94.2)
                                _buildQuickReturnButton(provider),
                              
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
  
  Widget _buildAppBar(RadioProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () {
              _showMenuDrawer();
            },
          ),
          
          // Title with glow effect for 94.2
          Column(
            children: [
              Text(
                'Radio',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '94.2 FM',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(0.5),
                      offset: Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Favorite button
          IconButton(
            icon: Icon(
              provider.currentStation?.isFavorite ?? false
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: provider.currentStation?.isFavorite ?? false
                  ? Colors.red
                  : Colors.white,
              size: 28,
            ),
            onPressed: () {
              if (provider.currentStation != null) {
                provider.toggleFavorite(provider.currentStation!);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.currentStation!.isFavorite
                          ? 'Ajouté aux favoris'
                          : 'Retiré des favoris',
                    ),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeIndicator(RadioProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: provider.useFmRadio 
            ? Colors.green.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: provider.useFmRadio ? Colors.green : Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            provider.useFmRadio ? Icons.radio : Icons.wifi,
            color: provider.useFmRadio ? Colors.green : Colors.blue,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            provider.useFmRadio 
                ? 'Mode FM (antenne: écouteurs)' 
                : 'Mode Streaming',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickReturnButton(RadioProvider provider) {
    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      openColor: Colors.transparent,
      middleColor: Colors.transparent,
      transitionType: ContainerTransitionType.fade,
      closedBuilder: (context, action) {
        return GestureDetector(
          onTap: () {
            provider.setFrequency(94.2);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Retour à 94.2 MHz'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.primary,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Revenir à 94.2 MHz',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, action) {
        return Container(); // Page de détails si nécessaire
      },
    );
  }
  
  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.glassBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 'Accueil', isSelected: true),
          _buildNavItem(Icons.explore, 'Explorer'),
          _buildNavItem(Icons.favorite, 'Favoris'),
          _buildNavItem(Icons.settings, 'Paramètres'),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        // Navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label - En développement'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.white54,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  void _changeFrequency(RadioProvider provider, double delta) {
    double newFreq = provider.currentFrequency + delta;
    if (newFreq >= 87.5 && newFreq <= 108.0) {
      provider.setFrequency(newFreq);
      
      // Feedback haptique pour 94.2
      if ((newFreq - 94.2).abs() < 0.1) {
        // Vibration légère
      }
    }
  }
  
  void _showMenuDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.all(12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('À propos', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text('Partager', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.white),
              title: Text('Noter l\'app', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}