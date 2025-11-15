import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Theme colors reused from admin panel
class AdminColors {
  static const primary = Color(0xFF0B3A8C);
  static const surface = Colors.white;
  static const subtleBg = Color(0xFFF5F8FF);
  static const border = Color(0xFFE6ECF8);
  static const textPrimary = Color(0xFF0F1A2E);
  static const textSecondary = Color(0xFF4D5B7C);
  static const success = Color(0xFF1B9E5A);
  static const danger = Color(0xFFD64545);
}

class EstablishmentDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String heroTag;

  const EstablishmentDetailPage({
    Key? key,
    required this.docId,
    required this.data,
    required this.heroTag,
  }) : super(key: key);

  @override
  State<EstablishmentDetailPage> createState() => _EstablishmentDetailPageState();
}

class _EstablishmentDetailPageState extends State<EstablishmentDetailPage> {
  bool _updating = false;

  Map<String, dynamic> get d => widget.data;
  
  /// Get image providers - handles both Base64 and URLs
  List<ImageProvider> get imageProviders {
    try {
      final images = d['images'] ?? [];
      if (images is! List) {
        debugPrint('Warning: Images is not a list: ${images.runtimeType}');
        return [];
      }
      
      List<ImageProvider> providers = [];
      for (var img in images) {
        if (img != null && img.toString().isNotEmpty) {
          providers.add(_getImageProvider(img.toString()));
        }
      }
      debugPrint('Loaded ${providers.length} images');
      return providers;
    } catch (e) {
      debugPrint('Error getting image providers: $e');
      return [];
    }
  }

  String get status => (d['status'] ?? 'pending').toString();

  /// Convert Base64 or URL string to ImageProvider
  ImageProvider _getImageProvider(String imageData) {
    if (imageData.isEmpty) {
      return const AssetImage('assets/placeholder.png');
    }

    try {
      // Check if it's a URL
      if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
        debugPrint('Loading image from URL');
        return NetworkImage(imageData);
      }

      // Try to decode as Base64
      try {
        final cleanData = imageData.replaceAll(RegExp(r'\s'), '');
        debugPrint('Attempting Base64 decode, length: ${cleanData.length}');
        
        final Uint8List bytes = base64Decode(cleanData);
        debugPrint('Base64 decoded successfully, bytes: ${bytes.length}');
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Base64 decode failed: $e');
      }
    } catch (e) {
      debugPrint('Error in _getImageProvider: $e');
    }

    return const AssetImage('assets/placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    final title = (d['name'] ?? '').toString();
    final address = (d['address'] ?? '').toString();
    final firstImage = imageProviders.isNotEmpty
        ? imageProviders.first
        : const AssetImage('assets/placeholder.png') as ImageProvider;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AdminColors.subtleBg,
      body: Stack(
        children: [
          // Header image
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Hero(
              tag: widget.heroTag,
              child: _HeaderImage(imageProvider: firstImage),
            ),
          ),

          // Main white content
          Positioned(
            top: 320,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AdminColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AdminColors.textSecondary, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              color: AdminColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Image carousel
                    if (imageProviders.length > 1)
                      _ImageCarousel(imageProviders: imageProviders.skip(1).toList()),
                    if (imageProviders.length > 1) const SizedBox(height: 16),

                    const _SectionTitle('About'),
                    _PText(d['description'] ?? 'No description provided.'),
                    const SizedBox(height: 16),

                    const _SectionTitle('Details'),
                    const SizedBox(height: 8),
                    _InfoRow('Type', d['type']),
                    _InfoRow('Contact', d['contactNumber']),
                    _InfoRow('Owner Email', d['ownerEmail']),
                    _InfoRow('Owner ID', d['ownerId']),
                    
                    // Status Badge Row
                    _StatusBadgeRow(status: status),
                    
                    if (d['createdAt'] != null)
                      _InfoRow(
                        'Submitted At',
                        _formatTimestamp(d['createdAt']),
                      ),
                    if (d['rejectionReason'] != null &&
                        (d['status'] == 'rejected'))
                      _InfoRow('Rejection Reason', d['rejectionReason']),

                    // Business Hours
                    if (d['businessHours'] != null && (d['businessHours'] as List).isNotEmpty)
                      ...[
                        const SizedBox(height: 16),
                        const _SectionTitle('Business Hours'),
                        const SizedBox(height: 8),
                        _BusinessHoursList(
                          hours: (d['businessHours'] as List).cast<Map<String, dynamic>>(),
                        ),
                      ],

                    // Transportation
                    if (d['transportOptions'] != null && (d['transportOptions'] as List).isNotEmpty)
                      ...[
                        const SizedBox(height: 16),
                        const _SectionTitle('Transportation Routes'),
                        const SizedBox(height: 8),
                        _TransportationList(
                          options: (d['transportOptions'] as List).cast<Map<String, dynamic>>(),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _GlassBackButton(
              onTap: () => Navigator.pop(context),
            ),
          ),

          // Bottom action bar - ONLY SHOW IF PENDING
          if (status.toLowerCase() == 'pending')
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: AdminColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _updating ? null : () => _onReject(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminColors.danger,
                            side: const BorderSide(color: AdminColors.danger),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _updating ? null : () => _onApprove(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          icon: _updating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check),
                          label: Text(_updating ? 'Updating...' : 'Approve'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return timestamp.toDate().toString().substring(0, 16);
      }
    } catch (e) {
      debugPrint('Error formatting timestamp: $e');
    }
    return 'Unknown';
  }

  // ignore: unused_element
  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return AdminColors.success;
      case 'rejected':
        return AdminColors.danger;
      default:
        return AdminColors.primary;
    }
  }

  Future<void> _onApprove(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: 'Approve Submission',
        message: 'This will mark the establishment as approved and publish it.',
        confirmLabel: 'Approve',
        confirmColor: AdminColors.primary,
      ),
    );
    if (confirm != true) return;

    setState(() => _updating = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      // Get the document data
      final docSnapshot = await FirebaseFirestore.instance
          .collection('establishment_submissions')
          .doc(widget.docId)
          .get();
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      
      // 1. Save to main 'establishments' collection
      await FirebaseFirestore.instance
          .collection('establishments')
          .doc(widget.docId)
          .set({
            ...data,
            'status': 'approved',
            'reviewedAt': FieldValue.serverTimestamp(),
            'reviewedBy': uid,
            'rejectionReason': FieldValue.delete(),
          });
      
      // 2. Update status in submissions collection
      await FirebaseFirestore.instance
          .collection('establishment_submissions')
          .doc(widget.docId)
          .update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': uid,
        'rejectionReason': FieldValue.delete(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Establishment approved and published.'),
          backgroundColor: AdminColors.primary,
          duration: Duration(seconds: 2),
        ));
        setState(() {
          widget.data['status'] = 'approved';
          widget.data.remove('rejectionReason');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AdminColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _onReject(BuildContext context) async {
    final reason = await showDialog<String?>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason == null) return;

    setState(() => _updating = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance
          .collection('establishment_submissions')
          .doc(widget.docId)
          .update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': uid,
        'rejectionReason': reason,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Submission rejected successfully.'),
          backgroundColor: AdminColors.danger,
          duration: Duration(seconds: 2),
        ));
        setState(() {
          widget.data['status'] = 'rejected';
          widget.data['rejectionReason'] = reason;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AdminColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }
}

/// Translucent back button
class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final ImageProvider imageProvider;
  const _HeaderImage({required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 460,
      decoration: BoxDecoration(
        color: AdminColors.subtleBg,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            debugPrint('Header image load error: $exception');
          },
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
        ),
      ),
      child: imageProvider is AssetImage
          ? Center(
              child: Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey.withOpacity(0.5),
              ),
            )
          : null,
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<ImageProvider> imageProviders;
  const _ImageCarousel({required this.imageProviders});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageProviders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.86),
            onPageChanged: (i) => setState(() => idx = i),
            itemCount: widget.imageProviders.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: AdminColors.subtleBg,
                  child: Image(
                    image: widget.imageProviders[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      return child;
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AdminColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Carousel image error: $error');
                      return Container(
                        color: AdminColors.subtleBg,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AdminColors.textSecondary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.imageProviders.length, (i) {
            final active = i == idx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: active ? 20 : 8,
              decoration: BoxDecoration(
                color: active ? AdminColors.primary : AdminColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 20,
        color: AdminColors.textPrimary,
      ),
    );
  }
}

class _PText extends StatelessWidget {
  final String text;
  const _PText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AdminColors.textSecondary,
        height: 1.5,
        fontSize: 14.5,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final dynamic value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AdminColors.subtleBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: AdminColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Professional Status Badge Row
class _StatusBadgeRow extends StatelessWidget {
  final String status;
  
  const _StatusBadgeRow({
    required this.status,
  });

  Color _getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case 'approved':
        return AdminColors.success;
      case 'rejected':
        return AdminColors.danger;
      default:
        return AdminColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = status[0].toUpperCase() + status.substring(1);
    final isPending = status.toLowerCase() == 'pending';
    final statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Icon(
                  isPending ? Icons.schedule : 
                    (status.toLowerCase() == 'approved' ? Icons.check_circle : Icons.cancel),
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Business Hours Display
class _BusinessHoursList extends StatelessWidget {
  final List<Map<String, dynamic>> hours;
  const _BusinessHoursList({required this.hours});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: hours.map((h) {
        final day = h['day'] ?? 'Unknown';
        final isClosed = h['isClosed'] ?? false;
        final open = h['openTime'] ?? '9:00 AM';
        final close = h['closeTime'] ?? '9:00 PM';

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AdminColors.subtleBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  isClosed ? 'Closed' : '$open - $close',
                  style: TextStyle(
                    color: isClosed
                        ? AdminColors.danger
                        : AdminColors.textSecondary,
                    fontWeight: isClosed ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Transportation Routes Display
class _TransportationList extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  const _TransportationList({required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.asMap().entries.map((entry) {
        int idx = entry.key;
        final option = entry.value;
        final routes = (option['routes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final generalNote = option['generalNote'] ?? '';

        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AdminColors.subtleBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Route ${idx + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...routes.asMap().entries.map((r) {
                final route = r.value;
                final mode = route['mode'] ?? 'Unknown';
                final duration = route['duration'] ?? '-';
                final fare = route['fare'] ?? '-';
                final note = route['note'] ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• $mode ($duration, $fare)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AdminColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (note.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 16),
                          child: Text(
                            'Note: $note',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              if (generalNote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Note: $generalNote',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[900],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Confirmation Dialog
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AdminColors.textPrimary,
                )),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: AdminColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel',
                        style: TextStyle(color: AdminColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reject Dialog
class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _valid = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Reject Submission',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AdminColors.textPrimary,
                )),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Please provide a reason for rejection:',
                style: TextStyle(color: AdminColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason',
                filled: true,
                fillColor: AdminColors.subtleBg,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: AdminColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AdminColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop<String?>(context, null),
                    child: const Text('Cancel',
                        style: TextStyle(color: AdminColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _valid
                        ? () => Navigator.pop<String?>(
                            context, _controller.text.trim())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
