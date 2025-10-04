import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_review.dart';

class ReviewPage extends StatefulWidget {
  final String cafeTitle;
  const ReviewPage({super.key, required this.cafeTitle});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int selectedRating = 0;

  // --- Modern, blue-and-white edit dialog with safe context ---
  void _showEditReviewDialog(String reviewId, Map<String, dynamic> review) {
    TextEditingController editController =
        TextEditingController(text: review['comment']);
    int editRating = review['rating'] ?? 0;
    bool isUpdating = false;

    // Save the root context (for snackbar)
    final rootContext = context;

    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Your Review",
                      style: TextStyle(
                        color: Color(0xFF0B55A0),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Star rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: editRating > index
                                ? Color(0xFF0B55A0)
                                : Colors.grey[300],
                            size: 32,
                          ),
                          splashRadius: 22,
                          onPressed: () {
                            setDialogState(() => editRating = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    // Review input
                    TextField(
                      controller: editController,
                      maxLines: 3,
                      cursorColor: Color(0xFF0B55A0),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: "Your review",
                        labelStyle: TextStyle(
                          color: Color(0xFF0B55A0),
                          fontWeight: FontWeight.w500,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF0B55A0),
                            width: 2,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFF0B55A0),
                              side: BorderSide(color: Color(0xFF0B55A0), width: 1.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUpdating
                                ? null
                                : () async {
                                    if (editRating == 0 ||
                                        editController.text.trim().isEmpty) {
                                      // Use rootContext for Snackbar to avoid deactivated context
                                      ScaffoldMessenger.of(rootContext).showSnackBar(
                                        SnackBar(
                                          content: Text('Please provide a rating and a comment.'),
                                          backgroundColor: Colors.red[400],
                                        ),
                                      );
                                      return;
                                    }
                                    setDialogState(() => isUpdating = true);
                                    await FirebaseFirestore.instance
                                        .collection('cafes')
                                        .doc(widget.cafeTitle)
                                        .collection('reviews')
                                        .doc(reviewId)
                                        .update({
                                      'rating': editRating,
                                      'comment': editController.text.trim(),
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    setDialogState(() => isUpdating = false);
                                    // Only pop if this context is still active
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.pop(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0B55A0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: isUpdating
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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

  // --- Confirm delete dialog ---
  void _confirmDeleteReview(String reviewId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Review"),
        content: Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('cafes')
                  .doc(widget.cafeTitle)
                  .collection('reviews')
                  .doc(reviewId)
                  .delete();
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/images/arco_diez.jpg',
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Review Content
          Positioned.fill(
            top: 200,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Give it a rate!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          size: 32,
                          color: selectedRating > index
                              ? Color(0xFF0B55A0)
                              : Colors.grey[300],
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  // Labels under stars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Bad', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('Excellent', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Visitor's Reviews Header & Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Visitor’s reviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 1, 1, 1),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddReviewPage(cafeTitle: widget.cafeTitle),
                            ),
                          );
                        },
                        icon: Icon(Icons.add, size: 16, color: Colors.white),
                        label: Text(
                          'Add your review',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0B55A0),
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Firestore Reviews Stream (per-cafe)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('cafes')
                          .doc(widget.cafeTitle)
                          .collection('reviews')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Text(
                                "No reviews yet. Be the first to review!",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => SizedBox(height: 18),
                          itemBuilder: (context, idx) {
                            final doc = docs[idx];
                            final data = doc.data() as Map<String, dynamic>? ?? {};
                            return reviewCard(doc.id, data, currentUserId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reviewCard(String reviewId, Map<String, dynamic> review, String? currentUserId) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (review['userPhotoUrl'] != null && review['userPhotoUrl'] != "")
                CircleAvatar(
                  backgroundImage: NetworkImage(review['userPhotoUrl']),
                  radius: 20,
                )
              else
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white),
                  radius: 20,
                ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? "Anonymous",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(review['timestamp']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (review['userId'] == currentUserId)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditReviewDialog(reviewId, review);
                    } else if (value == 'delete') {
                      _confirmDeleteReview(reviewId);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: index < (review['rating'] ?? 0)
                    ? Colors.orange
                    : Colors.grey[300],
              );
            }),
          ),
          SizedBox(height: 8),
          Text(review['comment'] ?? '', style: TextStyle(fontSize: 14)),
          if (review['imageUrl'] != null && review['imageUrl'] != "")
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  review['imageUrl'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "";
    final date = timestamp is DateTime
        ? timestamp
        : (timestamp as Timestamp).toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays >= 1) {
      return "${diff.inDays} day${diff.inDays > 1 ? "s" : ""} ago";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago";
    } else {
      return "Just now";
    }
  }
}
