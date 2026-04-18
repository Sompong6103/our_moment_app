import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';

class EventMapScreen extends StatelessWidget {
  final String? locationName;
  final double? latitude;
  final double? longitude;

  const EventMapScreen({
    super.key,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  double get _lat => latitude ?? 0;
  double get _lng => longitude ?? 0;
  String get _name => locationName ?? 'Event Location';
  bool get _hasLocation => latitude != null && longitude != null;

  Future<void> _openExternalMap() async {
    Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://maps.apple.com/?q=$_lat,$_lng&z=16');
    } else {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    }
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      final fallback = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
      await launchUrl(fallback);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventLatLng = LatLng(_lat, _lng);

    return AppDetailScaffold(
      title: 'Event Map',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Map ──
            Expanded(
              child: _hasLocation
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: eventLatLng,
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.ourmoment.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: eventLatLng,
                                width: 180,
                                height: 60,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _name,
                                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.location_on, color: AppColors.primary, size: 28),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text('No location set', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // ── Location info ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        const Text('Event Location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Open Maps Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _hasLocation ? _openExternalMap : null,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open Maps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}