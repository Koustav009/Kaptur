import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/theme_toggle_button.dart';

class HomeScreen extends GetView<HomeController> {
  final AuthController _authController = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _authController.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Welcome Section ---
            Text(
              "Welcome Back!",
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's what's happening with your events.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            // --- Stats Overview ---
            Obx(() => Row(
                  children: [
                    _buildStatCard(
                      context,
                      "Events",
                      controller.totalEvents.toString(),
                      Icons.event_note_rounded,
                      cs.primary,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      "Photos",
                      controller.totalImages.toString(),
                      Icons.photo_library_rounded,
                      cs.secondary,
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            Obx(() => _buildStorageCard(context)),

            const SizedBox(height: 40),

            // --- Recent Events Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Events", style: theme.textTheme.headlineSmall),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Events List ---
            Obx(() => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.events.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = controller.events[index];
                    return _buildEventTile(context, event);
                  },
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add event logic
        },
        label: const Text("Create Event"),
        icon: const Icon(Icons.add),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(value, style: theme.textTheme.displayMedium?.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.cloud_done_rounded, color: Colors.orange, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Storage Used", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  controller.formattedTotalStorage,
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 22, color: cs.primary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, dynamic event) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM dd, yyyy').format(event.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.folder_copy_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "$dateStr • ${event.imageCount} Photos",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${event.sizeInMb.toStringAsFixed(1)} MB",
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
