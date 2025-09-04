import 'package:flutter/material.dart';
import 'add_review.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int selectedRating = 0;

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Tung tung tung Sahur',
      'time': '4 mos ago',
      'rating': 5,
      'comment':
          'Best place to chill alone and with friends. Fully furnished place with WI-FI. Have a clean and neat restroom. The music was so relaxing.',
      'avatar': 'assets/images/tung.png',
    },
    {
      'name': 'Bombardino Crocodilo',
      'time': '4 mos ago',
      'rating': 5,
      'comment':
          'Just a random afternoon looking for a coffee with my partner. I loved how quiet and peaceful the cafe was. Coffee was nice. So was the pie. 5 stars for sure.',
      'avatar': 'assets/images/bomb.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Text
                    Center(
                      child: Text(
                        'Give it a rate!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                            color:
                                selectedRating > index
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
                          Text('Bad', style: TextStyle(fontSize: 12)),
                          Text('Excellent', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Ratings Panel
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ratingBox(
                            'Foursquare',
                            'Not rated yet',
                            'assets/images/fsq.png',
                          ),
                          ratingBox(
                            'Google',
                            '4.4★',
                            'assets/images/google.png',
                          ),
                          ratingBox('Facebook', '3.7★', 'assets/images/fb.png'),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Visitor's Reviews Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Visitor’s reviews",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReviewPage(),
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

                    // Reviews
                    ...reviews.map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: reviewCard(review),
                      ),
                    ),
                  ],
                ),
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

  Widget ratingBox(String source, String rating, String iconPath) {
    return Column(
      children: [
        Image.asset(iconPath, width: 32, height: 32),
        SizedBox(height: 8),
        Text(rating, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(source, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget reviewCard(Map<String, dynamic> review) {
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
              CircleAvatar(
                backgroundImage: AssetImage(review['avatar']),
                radius: 20,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    review['time'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
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
                color:
                    index < review['rating'] ? Colors.orange : Colors.grey[300],
              );
            }),
          ),
          SizedBox(height: 8),
          Text(review['comment'], style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
