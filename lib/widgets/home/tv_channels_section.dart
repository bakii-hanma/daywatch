import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../design_system/colors.dart';
import '../../models/tv_channel_model.dart';
import '../../screens/simple_tv_player_screen.dart';

class TvChannelsSection extends StatelessWidget {
  final String title;
  final List<TvChannelModel> channels;
  final bool isLoading;
  final VoidCallback? onSeeMoreTap;

  const TvChannelsSection({
    super.key,
    required this.title,
    required this.channels,
    required this.isLoading,
    this.onSeeMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && channels.isEmpty) return const SizedBox.shrink();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextColor(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeMoreTap != null)
                GestureDetector(
                  onTap: onSeeMoreTap,
                  child: Text(
                    'Voir +',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Liste horizontale
        SizedBox(
          height: 104,
          child: isLoading && channels.isEmpty
              ? _buildShimmerList(isDarkMode)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    return _buildChannelCard(context, channel, isDarkMode, textColor);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChannelCard(
    BuildContext context,
    TvChannelModel channel,
    bool isDarkMode,
    Color textColor,
  ) {
    final logoUrl = channel.logo;
    final containerColor = isDarkMode ? AppColors.surfaceDark : AppColors.cardLight;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SimpleTvPlayerScreen(channel: channel),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la chaîne
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: logoUrl.isNotEmpty
                    ? (logoUrl.startsWith('http')
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackLogo(channel.name),
                          )
                        : Image.asset(
                            logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackLogo(channel.name),
                          ))
                    : _buildFallbackLogo(channel.name),
              ),
            ),
            const SizedBox(height: 8),
            // Nom de la chaîne
            Text(
              channel.name,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLogo(String name) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      alignment: Alignment.center,
      child: Icon(
        Icons.tv,
        size: 20,
        color: AppColors.primary.withOpacity(0.8),
      ),
    );
  }

  Widget _buildShimmerList(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[850]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}
