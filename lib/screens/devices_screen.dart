import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';
import '../services/user_storage_service.dart';
import '../utils/alert_utils.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<DeviceApiModel> _devices = [];
  String? _currentDeviceId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final currentId = await UserStorageService.getDeviceId();
      final devices = await DeviceService.listDevices();
      
      setState(() {
        _currentDeviceId = currentId;
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des appareils: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        AlertUtils.showError(
          context: context,
          message: 'Impossible de charger la liste des appareils.',
          debugDetails: e.toString(),
        );
      }
    }
  }

  Future<void> _disconnectDevice(DeviceApiModel device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnecter l\'appareil'),
        content: Text('Êtes-vous sûr de vouloir déconnecter l\'appareil "${device.deviceName ?? 'Appareil sans nom'}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await DeviceService.disconnectDevice(device.deviceId);
      
      if (success) {
        if (mounted) {
          AlertUtils.showSuccess(
            context: context,
            message: 'Appareil déconnecté avec succès.',
          );
        }
        await _loadDevices();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          AlertUtils.showError(
            context: context,
            message: 'Erreur lors de la déconnexion de l\'appareil.',
          );
        }
      }
    }
  }

  Future<void> _disconnectOthers() async {
    if (_currentDeviceId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnecter les autres appareils'),
        content: const Text('Êtes-vous sûr de vouloir déconnecter tous les autres appareils associés à votre compte ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Tout déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await DeviceService.disconnectOthers(_currentDeviceId!);
      
      if (success) {
        if (mounted) {
          AlertUtils.showSuccess(
            context: context,
            message: 'Tous les autres appareils ont été déconnectés.',
          );
        }
        await _loadDevices();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          AlertUtils.showError(
            context: context,
            message: 'Erreur lors de la déconnexion des autres appareils.',
          );
        }
      }
    }
  }

  IconData _getDeviceIcon(String? deviceType) {
    if (deviceType == null) return Icons.device_unknown_rounded;
    final type = deviceType.toLowerCase();
    if (type.contains('mobile') || type.contains('phone') || type.contains('android') || type.contains('ios')) {
      return Icons.smartphone_rounded;
    } else if (type.contains('desktop') || type.contains('computer') || type.contains('laptop') || type.contains('windows') || type.contains('mac')) {
      return Icons.laptop_chromebook_rounded;
    } else if (type.contains('tv')) {
      return Icons.tv_rounded;
    }
    return Icons.devices_rounded;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
    final textColor = AppColors.getTextColor(isDarkMode);
    final cardColor = AppColors.getWidgetBackgroundColor(isDarkMode);
    
    // Filtrer les autres appareils
    final otherDevices = _devices.where((d) => d.deviceId != _currentDeviceId && d.isConnected).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appareils connectés',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDevices,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gérez les appareils connectés à votre compte DayWatch et déconnectez ceux que vous n\'utilisez plus.',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // SECTION APPAREIL ACTUEL
                    Text(
                      'Cet appareil',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ..._devices
                        .where((d) => d.deviceId == _currentDeviceId)
                        .map((d) => _buildDeviceCard(d, true, cardColor, textColor, isDarkMode)),
                    
                    const SizedBox(height: 32),
                    
                    // SECTION AUTRES APPAREILS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Autres appareils connectés (${otherDevices.length})',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (otherDevices.isNotEmpty)
                          TextButton(
                            onPressed: _disconnectOthers,
                            child: const Text(
                              'Tout déconnecter',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (otherDevices.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.devices_other_rounded,
                                size: 64,
                                color: textColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun autre appareil connecté',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...otherDevices.map(
                        (d) => _buildDeviceCard(d, false, cardColor, textColor, isDarkMode),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDeviceCard(
    DeviceApiModel device,
    bool isCurrent,
    Color cardColor,
    Color textColor,
    bool isDarkMode,
  ) {
    final subtleTextColor = AppColors.getTextSecondaryColor(isDarkMode);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: isCurrent
            ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône de l'appareil
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary.withOpacity(0.1)
                  : textColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getDeviceIcon(device.deviceType),
              color: isCurrent ? AppColors.primary : textColor.withOpacity(0.7),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Détails de l'appareil
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.deviceName ?? 'Appareil sans nom',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Actif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${device.operatingSystem ?? 'Système inconnu'} • v${device.appVersion ?? '1.0.0'}',
                  style: TextStyle(
                    color: subtleTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'IP: ${device.ipAddress ?? 'Inconnue'} • Actif ${_formatTimeAgo(device.lastActive)}',
                  style: TextStyle(
                    color: subtleTextColor.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Bouton de déconnexion pour les autres appareils
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: () => _disconnectDevice(device),
              tooltip: 'Déconnecter cet appareil',
            ),
        ],
      ),
    );
  }
}
