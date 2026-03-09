import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/equb_group_model.dart';
import '../../../core/theme/app_theme.dart';
import '../abay_icon.dart';

class GroupSelectorList extends StatelessWidget {
  final List<EqubGroupModel> groups;
  final int selectedIndex;
  final Function(int) onSelected;
  final bool isDark;

  const GroupSelectorList({
    super.key,
    required this.groups,
    required this.selectedIndex,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final group = groups[index];

          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              width: 85,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black12),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AbayIcon(
                    name: group.name,
                    width: 32,
                    height: 32,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      group.name ?? 'Group',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
