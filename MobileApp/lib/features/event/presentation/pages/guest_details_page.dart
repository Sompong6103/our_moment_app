import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../domain/models/event_model.dart';

class GuestDetailsPage extends StatefulWidget {
  final EventModel event;

  const GuestDetailsPage({super.key, required this.event});

  @override
  State<GuestDetailsPage> createState() => _GuestDetailsPageState();
}

class _GuestDetailsPageState extends State<GuestDetailsPage> {
  final _allergyController = TextEditingController();
  final _wishController = TextEditingController();
  int _followers = 1;

  @override
  void dispose() {
    _allergyController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  void _confirm() {
    // TODO: save guest details to backend
    // Pop back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined ${widget.event.title} successfully!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Guests Details',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Food Allergy ──
                  const Text(
                    'Food allergy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _allergyController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Shellfish, Nuts, Dairy...',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Well Wishes ──
                  const Text(
                    'Well wishes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _wishController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '"May your love grow stronger each passing year..."',
                      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Followers ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Followers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          _CounterButton(
                            icon: Icons.remove,
                            onTap: () {
                              if (_followers > 1) setState(() => _followers--);
                            },
                          ),
                          Container(
                            width: 44,
                            alignment: Alignment.center,
                            child: Text(
                              '$_followers',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                          _CounterButton(
                            icon: Icons.add,
                            onTap: () => setState(() => _followers++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Confirm Button ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Confirm to Join the event',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
