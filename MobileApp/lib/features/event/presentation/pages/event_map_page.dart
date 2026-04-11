import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';

class EventMapScreen extends StatelessWidget {
  const EventMapScreen({super.key});

  // สถานที่งาน (mock — ใช้ค่าจริงได้เมื่อเชื่อมกับ model)
  static const _eventLat = 18.7953;
  static const _eventLng = 98.9523;
  static const _eventName = 'Rao Grand 2, Chiang Mai';
  static final _eventLatLng = LatLng(_eventLat, _eventLng);

  Future<void> _openExternalMap() async {
    Uri url;
    if (Platform.isIOS) {
      // Apple Maps
      url = Uri.parse('https://maps.apple.com/?q=$_eventLat,$_eventLng&z=16');
    } else {
      // Google Maps
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_eventLat,$_eventLng');
    }
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // fallback to Google Maps web
      final fallback = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_eventLat,$_eventLng');
      await launchUrl(fallback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Event Map',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Map ──
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _eventLatLng,
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
                          point: _eventLatLng,
                          width: 50,
                          height: 50,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  _eventName,
                                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_eventName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('Event Location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                onPressed: _openExternalMap,
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