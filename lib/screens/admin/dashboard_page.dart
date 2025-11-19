import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, int>> _fetchStats() async {
    final col = FirebaseFirestore.instance.collection('establishment_submissions');
    final totalSnap = await col.get();
    final approvedSnap = await col.where('status', isEqualTo: 'approved').get();
    final pendingSnap = await col.where('status', isEqualTo: 'pending').get();
    final rejectedSnap = await col.where('status', isEqualTo: 'rejected').get();

    return {
      'total': totalSnap.size,
      'approved': approvedSnap.size,
      'pending': pendingSnap.size,
      'rejected': rejectedSnap.size,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard Overview",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(
                    title: 'Total Submissions',
                    value: stats['total'].toString(),
                    color: AdminColors.primary,
                    icon: Icons.bar_chart,
                  ),
                  _StatCard(
                    title: 'Approved',
                    value: stats['approved'].toString(),
                    color: AdminColors.success,
                    icon: Icons.check_circle,
                  ),
                  _StatCard(
                    title: 'Pending',
                    value: stats['pending'].toString(),
                    color: Colors.amber[700]!,
                    icon: Icons.pending_actions,
                  ),
                  _StatCard(
                    title: 'Rejected',
                    value: stats['rejected'].toString(),
                    color: AdminColors.danger,
                    icon: Icons.cancel_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Recent Submissions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const _RecentSubmissions(),
            ],
          ),
        );
      },
    );
  }
}

/// COLORS (inline)
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

/// STAT CARD
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AdminColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// RECENT SUBMISSIONS
class _RecentSubmissions extends StatelessWidget {
  const _RecentSubmissions();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('establishment_submissions')
          .orderBy('submittedAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("No recent submissions yet.",
              style: TextStyle(color: AdminColors.textSecondary));
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.store, color: AdminColors.primary),
              title: Text(data['name'] ?? 'Unnamed'),
              subtitle: Text("Status: ${data['status']}"),
            );
          }).toList(),
        );
      },
    );
  }
}
