import 'package:flutter/material.dart';
import '../../design_system/spacing.dart';
import 'section_header.dart';

class HorizontalSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final double itemWidth;
  final double sectionHeight;
  final bool showSeeMore;
  final VoidCallback? onSeeMoreTap;
  final bool isDarkMode;

  const HorizontalSection({
    Key? key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.itemWidth = AppSpacing.cardWidth,
    this.sectionHeight = AppSpacing.sectionHeightLarge,
    this.showSeeMore = true,
    this.onSeeMoreTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SectionHeader(
            title: title,
            showSeeMore: showSeeMore,
            onSeeMoreTap: onSeeMoreTap,
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: sectionHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Container(
                width: itemWidth,
                margin: EdgeInsets.only(
                  right: index < items.length - 1 ? AppSpacing.md : 0,
                ),
                child: itemBuilder(items[index], index),
              );
            },
          ),
        ),
      ],
    );
  }
}
