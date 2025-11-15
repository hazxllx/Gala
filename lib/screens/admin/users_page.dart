import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: Column(
        children: [
          _TopBar(onQueryChanged: (q) => setState(() => _query = q)),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  /// ------------------------------
  /// BUILD USER LIST
  /// ------------------------------
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const _EmptyState(message: "No registered users yet.");
        }

        final docs = snapshot.data!.docs;

        // Filter users by name/email search
        final filtered = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final name = (data['username'] ?? data['name'] ?? '')
              .toString()
              .toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final q = _query.toLowerCase().trim();
          return q.isEmpty || name.contains(q) || email.contains(q);
        }).toList();

        if (filtered.isEmpty) {
          return const _EmptyState(message: "No matching users found.");
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final doc = filtered[i];
            final data = doc.data() as Map<String, dynamic>;

            final username = data['username'] ?? data['name'] ?? 'Unnamed User';
            final email = data['email'] ?? 'No email';
            final role = data['role'] ?? 'User'; // Optional role field

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6ECF8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0B3A8C).withOpacity(0.1),
                  child: const Icon(Icons.person, color: Color(0xFF0B3A8C)),
                ),
                title: Text(
                  username,
                  style: const TextStyle(
                    color: Color(0xFF0F1A2E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "$email\nRole: $role",
                  style: const TextStyle(
                    color: Color(0xFF4D5B7C),
                    height: 1.4,
                  ),
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDeleteUser(context, doc.id, username);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Color(0xFFD64545), size: 18),
                          SizedBox(width: 8),
                          Text('Delete User'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ------------------------------
  /// DELETE CONFIRMATION DIALOG
  /// ------------------------------
  Future<void> _confirmDeleteUser(
      BuildContext context, String userId, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete '$username'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF4D5B7C)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD64545),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete the user document from Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("'$username' has been deleted."),
        backgroundColor: const Color(0xFFD64545),
      ));
    }
  }
}

/// ------------------------------
/// TOP BAR (Search)
/// ------------------------------
class _TopBar extends StatelessWidget {
  final ValueChanged<String> onQueryChanged;

  const _TopBar({required this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6ECF8)),
            ),
            child: TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Search users by username or email…',
                hintStyle: TextStyle(color: Color(0xFF4D5B7C)),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Color(0xFF4D5B7C)),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// EMPTY STATE
/// ------------------------------
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

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
            const Icon(Icons.person_outline, size: 40, color: Color(0xFF4D5B7C)),
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
