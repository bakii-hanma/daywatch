import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final Color textColor;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationsPressed;

  const ProfileHeader({
    super.key,
    required this.textColor,
    this.onSearchPressed,
    this.onNotificationsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Profil',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search_rounded, color: textColor),
              onPressed: onSearchPressed ?? () {},
            ),
            IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: textColor),
              onPressed: onNotificationsPressed ?? () {},
            ),
          ],
        ),
      ],
    );
  }
}
