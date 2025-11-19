import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'establishment_detail_page.dart';

class EstablishmentsPage extends StatefulWidget {
  const EstablishmentsPage({super.key});

  @override
  State<EstablishmentsPage> createState() => _EstablishmentsPageState();
}

class _EstablishmentsPageState extends State<EstablishmentsPage> {
  String _statusFilter = 'all';
  String _query = '';
  String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(
          onQueryChanged: (q) => setState(() => _query = q),
          onStatusChanged: (s) => setState(() => _statusFilter = s),
          status: _statusFilter,
          onCategoryChanged: (c) => setState(() => _categoryFilter = c),
          category: _categoryFilter,
        ),
        Expanded(child: _buildEstablishmentGrid()),
      ],
    );
  }

  Widget _buildEstablishmentGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('establishments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B3A8C)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const _EmptyState();
        }

        final docs = snapshot.data!.docs;
        final filtered = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final status = (data['status'] ?? 'approved').toString().toLowerCase();
          final type = (data['type'] ?? '').toString().toLowerCase();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final address = (data['address'] ?? '').toString().toLowerCase();
          final q = _query.toLowerCase().trim();

          final statusOk = _statusFilter == 'all' || status == _statusFilter;
          final categoryOk =
              _categoryFilter == 'All' || type == _categoryFilter.toLowerCase();
          final textOk =
              q.isEmpty || name.contains(q) || address.contains(q);

          return statusOk && categoryOk && textOk;
        }).toList();

        if (filtered.isEmpty) {
          return const _EmptyState(
            message: "No matching establishments found.",
          );
        }

        return LayoutBuilder(
          builder: (context, c) {
            final width = c.maxWidth;
            int crossAxisCount = 1;
            if (width >= 1200) crossAxisCount = 3;
            else if (width >= 760) crossAxisCount = 2;

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final doc = filtered[i];
                final data = doc.data() as Map<String, dynamic>;
                
                final images = data['images'] as List<dynamic>? ?? [];
                final String? imageData = images.isNotEmpty 
                    ? images.first as String? 
                    : null;
                
                final heroTag = 'est-hero-${doc.id}';

                return _EstablishmentCard(
                  heroTag: heroTag,
                  name: data['name'] ?? 'No Name',
                  address: data['address'] ?? 'No Address',
                  status: (data['status'] ?? 'approved').toString(),
                  imageData: imageData,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EstablishmentDetailPage(
                          docId: doc.id,
                          data: data,
                          heroTag: heroTag,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// TOP BAR WITH STATUS FILTER
class _TopBar extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onCategoryChanged;
  final String status;
  final String category;

  const _TopBar({
    required this.onQueryChanged,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.status,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      _StatusChip(
        label: 'All',
        value: 'all',
        selected: status == 'all',
        onTap: onStatusChanged,
      ),
      _StatusChip(
        label: 'Pending',
        value: 'pending',
        selected: status == 'pending',
        onTap: onStatusChanged,
      ),
      _StatusChip(
        label: 'Approved',
        value: 'approved',
        selected: status == 'approved',
        onTap: onStatusChanged,
      ),
      _StatusChip(
        label: 'Rejected',
        value: 'rejected',
        selected: status == 'rejected',
        onTap: onStatusChanged,
      ),
    ];

    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        children: [
          // Search
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6ECF8)),
            ),
            child: TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Search by name or address...',
                hintStyle: TextStyle(color: Color(0xFF4D5B7C)),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Color(0xFF4D5B7C)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Category:",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F1A2E),
                ),
              ),
              DropdownButton<String>(
                value: category,
                items: ['All', 'Cafe', 'Restaurant', 'Bar', 'Park']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => onCategoryChanged(v ?? 'All'),
                underline: const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Filter Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => chips[i],
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: chips.length,
            ),
          ),
        ],
      ),
    );
  }
}

/// STATUS CHIP
class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final ValueChanged<String> onTap;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B3A8C) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? const Color(0xFF0B3A8C) : const Color(0xFFE6ECF8)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF4D5B7C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// ESTABLISHMENT CARD
class _EstablishmentCard extends StatelessWidget {
  final String heroTag;
  final String name;
  final String address;
  final String status;
  final String? imageData;
  final VoidCallback onTap;

  const _EstablishmentCard({
    required this.heroTag,
    required this.name,
    required this.address,
    required this.status,
    required this.imageData,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF1B9E5A);
      case 'rejected':
        return const Color(0xFFD64545);
      case 'pending':
        return const Color(0xFF0B3A8C);
      default:
        return const Color(0xFF0B3A8C);
    }
  }

  ImageProvider _getImageProvider() {
    if (imageData == null || imageData!.isEmpty) {
      return const AssetImage('assets/placeholder.png');
    }

    try {
      if (imageData!.startsWith('http://') || imageData!.startsWith('https://')) {
        return NetworkImage(imageData!);
      }

      try {
        final cleanData = imageData!.replaceAll(RegExp(r'\s'), '');
        final bytes = base64Decode(cleanData);
        return MemoryImage(bytes);
      } catch (e) {
        debugPrint('Base64 decode error: $e');
      }
    } catch (e) {
      debugPrint('Image provider error: $e');
    }

    return const AssetImage('assets/placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6ECF8)),
          ),
          child: Column(
            children: [
              Hero(
                tag: heroTag,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    image: DecorationImage(
                      image: _getImageProvider(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF0F1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF4D5B7C),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: Color(0xFF4D5B7C)),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EMPTY STATE
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({this.message = "No establishments yet."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6ECF8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox, size: 40, color: Color(0xFF4D5B7C)),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF0B3A8C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
