// lib/widgets/header.dart
import 'package:flutter/material.dart';

class GalaHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? userPhotoUrl;

  const GalaHeader({super.key, this.userPhotoUrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),

              // Logo + Gala text
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    isDark ? 'assets/logo_white.png' : 'assets/logo.png',
                    height: isDark ? screenHeight * 0.05 : screenHeight * 0.035,
                    width: isDark ? screenHeight * 0.05 : null,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.37, 1.0],
                        colors: isDark
                            ? [Color(0xFF58BCF1), Color(0xFFFFFFFF)]
                            : [Color(0xFF041D66), Color(0xFF000000)],
                      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                    },
                    child: Text(
                      "Gala",
                      style: TextStyle(
                        fontFamily: 'Sarina',
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              // Avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: userPhotoUrl != null
                        ? NetworkImage(userPhotoUrl!)
                        : const AssetImage('assets/user.png') as ImageProvider,
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
