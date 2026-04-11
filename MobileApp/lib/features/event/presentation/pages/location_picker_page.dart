import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

class SelectedLocation {
  final LatLng latLng;
  final String displayName;

  const SelectedLocation({required this.latLng, required this.displayName});
}

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late final MapController _mapController;
  LatLng? _selectedLatLng;
  String? _addressLabel;
  bool _loading = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<_SearchResult> _searchResults = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLatLng = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _loading = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json&addressdetails=1',
      );
      final response = await http.get(url, headers: {'User-Agent': 'OurMomentApp/1.0'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _addressLabel = data['display_name'] ?? 'Unknown location');
      }
    } catch (_) {
      setState(() => _addressLabel = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final response = await http.get(url, headers: {'User-Agent': 'OurMomentApp/1.0'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((e) => _SearchResult(
            displayName: e['display_name'],
            lat: double.parse(e['lat']),
            lon: double.parse(e['lon']),
          )).toList();
          _showResults = true;
        });
      }
    } catch (_) {}
  }

  void _selectSearchResult(_SearchResult result) {
    final pos = LatLng(result.lat, result.lon);
    setState(() {
      _selectedLatLng = pos;
      _addressLabel = result.displayName;
      _searchResults = [];
      _showResults = false;
      _searchCtrl.clear();
    });
    _mapController.move(pos, 16);
    FocusScope.of(context).unfocus();
  }

  void _onTapMap(TapPosition _, LatLng pos) {
    setState(() {
      _selectedLatLng = pos;
      _addressLabel = null;
    });
    _reverseGeocode(pos);
  }

  void _confirmLocation() {
    if (_selectedLatLng == null) return;
    Navigator.pop(
      context,
      SelectedLocation(
        latLng: _selectedLatLng!,
        displayName: _addressLabel ?? '${_selectedLatLng!.latitude.toStringAsFixed(5)}, ${_selectedLatLng!.longitude.toStringAsFixed(5)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _selectedLatLng ?? widget.initialLocation ?? const LatLng(13.7563, 100.5018); // Bangkok default
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
              onTap: _onTapMap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ourmoment.app',
              ),
              if (_selectedLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLatLng!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                    ),
                  ],
                ),
            ],
          ),

          // ── Top bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(12, topPadding + 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.buttonGrey,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _searchPlace,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: AppColors.buttonGrey,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search results ──
          if (_showResults && _searchResults.isNotEmpty)
            Positioned(
              top: topPadding + 68,
              left: 12,
              right: 12,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final r = _searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                      title: Text(r.displayName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      onTap: () => _selectSearchResult(r),
                    );
                  },
                ),
              ),
            ),

          // ── Bottom card ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                        child: _loading
                            ? const Text('Loading address...', style: TextStyle(fontSize: 14, color: Colors.grey))
                            : Text(
                                _addressLabel ?? 'Tap on the map to select location',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _addressLabel != null ? AppColors.textPrimary : AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _selectedLatLng != null ? _confirmLocation : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Confirm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  final String displayName;
  final double lat;
  final double lon;
  const _SearchResult({required this.displayName, required this.lat, required this.lon});
}
