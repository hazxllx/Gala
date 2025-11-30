import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onSettingsTap;
  const ProfilePage({
    super.key,
    required this.onSettingsTap,
    required String username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String photoUrl = '';
  String username = '';
  bool isLoading = true;
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadActivities();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!mounted) return;

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = data['email'] ?? '';
        photoUrl = data['photoUrl'] ?? '';
        username = data['username'] ?? FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'usernotfound23';
        isLoading = false;
      });
    } else {
      setState(() {
        username = FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'usernotfound23';
        isLoading = false;
      });
    }
  }

  Future<void> _loadActivities() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    List<Map<String, dynamic>> allActivities = [];

    try {
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .limit(10)
          .get();

      for (var doc in favoritesSnapshot.docs) {
        final data = doc.data();
        allActivities.add({
          'type': 'favorite',
          'title': doc.id,
          'subtitle': 'Added to favorites',
          'timestamp': data['addedAt'] as Timestamp?,
          'imagePath': data['imagePath'] as String?,
          'icon': Icons.favorite,
          'color': Colors.red,
        });
      }

      final cafeCollections = ['cafes', 'bars', 'restaurants'];
      for (var collection in cafeCollections) {
        final collectionSnapshot = await FirebaseFirestore.instance.collection(collection).get();
        for (var cafeDoc in collectionSnapshot.docs) {
          final ratingDoc = await FirebaseFirestore.instance
              .collection(collection)
              .doc(cafeDoc.id)
              .collection('ratings')
              .doc(uid)
              .get();

          if (ratingDoc.exists) {
            final rating = ratingDoc.data()?['rating'] ?? 0;
            final cafeData = cafeDoc.data();
            allActivities.add({
              'type': 'rating',
              'title': cafeDoc.id,
              'subtitle': 'Rated $rating stars',
              'timestamp': null,
              'imagePath': cafeData['imagePath'] as String?,
              'icon': Icons.star,
              'color': Colors.amber,
            });
          }
        }
      }

      allActivities.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      if (mounted) {
        setState(() {
          activities = allActivities.take(15).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading activities: $e');
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Recently';

    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool _isNetworkImage(String? path) {
    if (path == null) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safePaddingTop = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF181A1B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = isDark ? Colors.grey[300] : Colors.grey[800];
    final secondaryText = isDark ? Colors.grey[400] : Colors.black54;
    final cardColor = isDark ? const Color(0xFF232528) : Colors.white;
    final cardBorder = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    final fullName = (firstName + ' ' + lastName).trim().isEmpty
        ? 'User Not Found'
        : '$firstName $lastName';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 6.0,
                color: Colors.black54,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: widget.onSettingsTap,
              child: Image.asset(
                'assets/icons/settings.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_settings.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // inner container
          Positioned(
            top: safePaddingTop + size.height * 0.18,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07,
                vertical: size.height * 0.03,
              ),
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.015),
                          SizedBox(
                            width: size.width * 0.4,
                            height: size.height * 0.045,
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                      currentUsername: fullName,
                                      currentProfileImagePath: photoUrl.isNotEmpty ? photoUrl : null,
                                      onProfileUpdated: (updatedUsername, _, updatedImagePath) async {
                                        await _loadUserData();
                                      },
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  await _loadUserData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Edit profile',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.06),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Account',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: labelColor,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              username,
                              style: TextStyle(
                                fontSize: size.width * 0.038,
                                color: textColor,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Username',
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: secondaryText,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Your Activity',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: labelColor,
                              ),
                            ),
                          ),
                          // --------- No SizedBox or gap here ---------
                          if (activities.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                left: size.width * 0.04,
                                right: size.width * 0.04,
                                bottom: size.height * 0.03,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF222325) : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: size.width * 0.08,
                                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    'No Activity yet',
                                    style: TextStyle(
                                      fontSize: size.width * 0.035,
                                      color: secondaryText,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  Text(
                                    'Your recent activities will appear here',
                                    style: TextStyle(
                                      fontSize: size.width * 0.03,
                                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: activities.length,
                              itemBuilder: (context, index) {
                                final activity = activities[index];
                                final imagePath = activity['imagePath'] as String?;
                                final hasImage = imagePath != null && imagePath.isNotEmpty;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cardBorder,
                                      width: 1,
                                    ),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(16),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      if (hasImage)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: _isNetworkImage(imagePath)
                                              ? Image.network(
                                                  imagePath,
                                                  width: 65,
                                                  height: 65,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return _buildIconContainer(activity, isDark);
                                                  },
                                                )
                                              : Image.asset(
                                                  imagePath,
                                                  width: 65,
                                                  height: 65,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return _buildIconContainer(activity, isDark);
                                                  },
                                                ),
                                        )
                                      else
                                        _buildIconContainer(activity, isDark),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              activity['title'] as String,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              activity['subtitle'] as String,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTimestamp(activity['timestamp'] as Timestamp?),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: (activity['color'] as Color).withAlpha(30),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          activity['icon'] as IconData,
                                          color: activity['color'] as Color,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: size.height * 0.05),
                        ],
                      ),
                    ),
            ),
          ),
          // profile picture
          Positioned(
            top: safePaddingTop + size.height * 0.10,
            left: (size.width / 2) - (size.width * 0.12),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: size.width * 0.12,
                backgroundColor: Colors.white,
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/user.png') as ImageProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(Map<String, dynamic> activity, bool isDark) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: (activity['color'] as Color).withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        activity['icon'] as IconData,
        color: activity['color'] as Color,
        size: 30,
      ),
    );
  }
}
