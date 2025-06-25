import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

class CommentCard extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String comment;
  final String avatarPath;
  final bool isDarkMode;

  const CommentCard({
    Key? key,
    required this.userName,
    required this.timeAgo,
    required this.comment,
    required this.avatarPath,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(radius: 20, backgroundImage: AssetImage(avatarPath)),
              const SizedBox(width: 12),
              // Nom et temps
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        color: AppColors.getTextColor(isDarkMode),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: AppColors.getTextSecondaryColor(isDarkMode),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Commentaire
          Text(
            comment,
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
