import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../widgets/theme_toggle_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

/// HomeScreen is the primary dashboard where users view, create, update, and delete events.
/// 
/// NOTE FOR LEARNERS:
/// 1. `RefreshIndicator` allows users to pull down to re-fetch events from the Spring Boot backend (`GET /events`).
/// 2. `FloatingActionButton` opens a modal dialog (`_showEventDialog`) to create a new event (`POST /events`).
/// 3. `PopupMenuButton` on each event tile lets the user Edit (`PUT /events/{id}`) or Delete (`DELETE /events/{id}`) that event.
class HomeScreen extends GetView<HomeController> {
  final AuthController _authController = Get.put(AuthController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Events",
            onPressed: () => controller.fetchEvents(),
          ),
          const ThemeToggleButton(),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: "Menu",
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchEvents(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              Obx(
                () => Row(
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
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => _buildStorageCard(context)),

              const SizedBox(height: 40),

              // --- Recent Events Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Events", style: theme.textTheme.headlineSmall),
                  Obx(() => controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 16),

              // --- Events List ---
              Obx(
                () => controller.events.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.events.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final event = controller.events[index];
                          return _buildEventTile(context, event);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventDialog(context: context),
        label: const Text("Create Event"),
        icon: const Icon(Icons.add),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Right-side navigation drawer showing the user's profile photo,
  /// name, email and a logout option.
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- User Profile Section ---
            DrawerHeader(
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Obx(() {
                final user = _authController.currentUser.value;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildUserAvatar(user?.imageUrl, radius: 38),
                    const SizedBox(height: 12),
                    Text(
                      user?.name.isNotEmpty == true ? user!.name : "Kaptur User",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }),
            ),

            const Spacer(),

            // --- Logout Option ---
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows confirmation popup before logging out.
  void _showLogoutConfirmation(BuildContext context) {
    Get.back();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              _authController.logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  /// Circular profile photo from [imageUrl]; falls back to a person icon
  /// when the user has no photo or the image fails to load.
  Widget _buildUserAvatar(String? imageUrl, {double radius = 20}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.15),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person_rounded, size: radius),
              )
            : Icon(Icons.person_rounded, size: radius),
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
            Text(
              value,
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
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
            child: const Icon(
              Icons.cloud_done_rounded,
              color: Colors.orange,
              size: 30,
            ),
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
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 22,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 60, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              "No Events Found",
              style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Click 'Create Event' to start preserving your memories!",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
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
            child: Icon(
              Icons.folder_copy_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$dateStr • ${event.imageCount} Photos${event.eventLocation != null ? ' • ${event.eventLocation}' : ''}",
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEventDialog(context: context, existingEvent: event);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, event);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text("Edit Event"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Delete Event", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows a modal dialog to Create or Update an Event (`POST` or `PUT`).
  void _showEventDialog({required BuildContext context, dynamic existingEvent}) {
    final titleController = TextEditingController(text: existingEvent?.name ?? '');
    final descController = TextEditingController(text: existingEvent?.description ?? '');
    final dateController = TextEditingController(text: existingEvent?.eventDate ?? '');
    final locationController = TextEditingController(text: existingEvent?.eventLocation ?? '');

    final isEditing = existingEvent != null;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? "Update Event" : "Create New Event"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Event Title *",
                  hintText: "e.g., Annual Tech Gala",
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description (Optional)",
                  hintText: "Brief summary of the event",
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Event Date (Optional)",
                  hintText: "e.g., 2026-08-15",
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "Event Location (Optional)",
                  hintText: "e.g., Grand Ballroom, Bangalore",
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (isEditing) {
                controller.updateEvent(
                  existingEvent.id,
                  title: titleController.text,
                  description: descController.text,
                  eventDate: dateController.text,
                  eventLocation: locationController.text,
                );
              } else {
                controller.createEvent(
                  title: titleController.text,
                  description: descController.text,
                  eventDate: dateController.text,
                  eventLocation: locationController.text,
                );
              }
            },
            child: Text(isEditing ? "Update" : "Create"),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation popup before calling `deleteEvent`.
  void _showDeleteConfirmation(BuildContext context, dynamic event) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete '${event.name}'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Get.back();
              controller.deleteEvent(event.id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
