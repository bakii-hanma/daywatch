import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

class CommentInputField extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback? onSend;
  final String hintText;

  const CommentInputField({
    Key? key,
    required this.isDarkMode,
    this.onSend,
    this.hintText = 'Écrire un commentaire à propos du film',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.getSearchBackgroundColor(isDarkMode),
        border: Border(
          top: BorderSide(
            color: AppColors.getSearchBackgroundColor(isDarkMode),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getSearchBackgroundColor(isDarkMode),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: TextStyle(color: AppColors.getTextColor(isDarkMode)),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColors.getTextSecondaryColor(isDarkMode),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
