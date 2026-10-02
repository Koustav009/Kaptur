import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:kaptur/core/config/app_config.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/data/models/photo_model.dart';

import '../../../widgets/responsive_center.dart';
import '../../../widgets/theme_toggle_button.dart';
import '../controllers/event_detail_controller.dart';

/// EventDetailScreen shows a single event's details and its photo grid, and
/// lets the user upload new photos — via the picker (`FAB`) on all platforms,
/// or by drag & drop on web.
///
/// NOTE FOR LEARNERS:
/// 1. Tapping an event tile on the Home dashboard opens this screen (route
///    arguments carry the [EventModel]).
/// 2. `RefreshIndicator` re-fetches photos from `GET /events/{id}/photos`.
/// 3. While uploading, a progress card shows per-batch progress driven by the
///    TUS chunked PATCH loop in `TusUploader`.
class EventDetailScreen extends GetView<EventDetailController> {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.event.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Photos",
            onPressed: () => controller.fetchPhotos(),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: _wrapDropTarget(
        context,
        child: RefreshIndicator(
        onRefresh: () => controller.fetchPhotos(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: ResponsiveCenter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventDetailsCard(context),
                const SizedBox(height: 16),
                Obx(() => _buildStatsRow(context)),
                const SizedBox(height: 30),

                // --- Photos Section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Photos", style: theme.textTheme.headlineSmall),
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
                Obx(() => controller.isUploading.value
                    ? _buildUploadProgressCard(context)
                    : const SizedBox.shrink()),
                Obx(
                  () => controller.photos.isEmpty
                      ? _buildEmptyState(context)
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: controller.photos.length,
                          itemBuilder: (context, index) =>
                              _buildPhotoTile(context, controller.photos[index]),
                        ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.pickAndUploadImages(),
        label: const Text("Upload Photos"),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Wraps the screen body in a drag & drop zone on web so users can drop
  /// images directly (alongside the picker button). Other platforms keep the
  /// plain body — the gallery picker covers them.
  Widget _wrapDropTarget(BuildContext context, {required Widget child}) {
    if (!kIsWeb) return child;
    return DropTarget(
      onDragEntered: (_) => controller.isDragOver.value = true,
      onDragExited: (_) => controller.isDragOver.value = false,
      onDragDone: (detail) {
        LoggerUtility.debug(
            'DropTarget: ${detail.files.length} file(s) dropped');
        controller.addDroppedFiles(detail.files);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Obx(
            () => controller.isDragOver.value
                ? _buildDragOverlay(context)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Highlight overlay shown while files are dragged over the screen.
  Widget _buildDragOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return IgnorePointer(
      child: Container(
        color: cs.primary.withOpacity(0.12),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.primary, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_rounded,
                size: 48,
                color: cs.primary,
              ),
              const SizedBox(height: 12),
              Text("Drop images to upload", style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// Card with the event's title, description, date, location and creator.
  Widget _buildEventDetailsCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final event = controller.event;
    final dateStr = DateFormat('MMM dd, yyyy').format(event.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.folder_copy_rounded,
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Created on $dateStr"
                      "${event.creatorName != null ? ' by ${event.creatorName}' : ''}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(event.description!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (event.eventDate != null && event.eventDate!.isNotEmpty)
                _buildInfoChip(
                  context,
                  Icons.calendar_today_rounded,
                  event.eventDate!,
                ),
              if (event.eventLocation != null && event.eventLocation!.isNotEmpty)
                _buildInfoChip(
                  context,
                  Icons.location_on_outlined,
                  event.eventLocation!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Two small stat cards: photo count and total upload size.
  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget stat(String label, String value, IconData icon, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.displayMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 2),
                  Text(label, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        stat(
          "Photos",
          controller.photos.length.toString(),
          Icons.photo_library_rounded,
          cs.primary,
        ),
        const SizedBox(width: 16),
        stat(
          "Total Size",
          controller.formattedTotalSize,
          Icons.cloud_done_rounded,
          cs.secondary,
        ),
      ],
    );
  }

  /// Progress card shown while one or more photos are uploading.
  Widget _buildUploadProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Uploading ${controller.uploadFileName.value}…",
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: controller.uploadProgress.value,
              minHeight: 6,
            ),
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
            Icon(Icons.photo_library_outlined, size: 60, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              "No Photos Yet",
              style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor),
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb
                  ? "Tap 'Upload Photos' or drag & drop images here to start adding memories!"
                  : "Tap 'Upload Photos' to start adding memories to this event!",
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// A single photo tile: thumbnail from TUSd with a delete action overlay.
  Widget _buildPhotoTile(BuildContext context, PhotoModel photo) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final String? url = photo.downloadUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null && url.isNotEmpty && photo.isCompleted)
            Image.network(
              AppConfig.resolveMediaUrl(url),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: theme.cardColor,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: theme.cardColor,
                child: const Icon(Icons.broken_image_outlined),
              ),
            )
          else
            Container(
              color: theme.cardColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_top_rounded, color: cs.primary),
                  const SizedBox(height: 8),
                  Text(
                    photo.photoStatus,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.black.withOpacity(0.45),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _showDeletePhotoConfirmation(context, photo),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation popup before deleting a photo (destructive action).
  void _showDeletePhotoConfirmation(BuildContext context, PhotoModel photo) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Deletion"),
        content: Text(
          "Are you sure you want to delete '${photo.filename}'? This action cannot be undone.",
        ),
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
              controller.deletePhoto(photo.photoId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
