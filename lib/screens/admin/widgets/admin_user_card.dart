import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_responsive.dart';
import '../../../core/app_text_styles.dart';

class AdminUserCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final int badge;
  final Widget Function(BuildContext context) buildContent;

  const AdminUserCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buildContent,
    this.badge = 0,
  });

  @override
  State<AdminUserCard> createState() => _AdminUserCardState();
}

class _AdminUserCardState extends State<AdminUserCard> {
  bool _wasExpanded = false;

  void _onExpansionChanged(bool expanded) {
    if (expanded && !_wasExpanded) {
      setState(() => _wasExpanded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12 * s),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18 * s),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: const ListTileThemeData(dense: true),
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 4),
          childrenPadding: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, 14 * s),
          onExpansionChanged: _onExpansionChanged,
          leading: _AdminUserLeading(
            icon: Icons.person,
            badge: widget.badge,
            scale: s,
          ),
          title: Text(
            widget.title,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text,
              fontSize: 17 * s,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            widget.subtitle,
            style: AppTextStyles.body.copyWith(
              fontSize: 13 * s,
              color: AppColors.secondaryText,
            ),
          ),
          children: [
            if (_wasExpanded) widget.buildContent(context),
          ],
        ),
      ),
    );
  }
}

class _AdminUserLeading extends StatelessWidget {
  final IconData icon;
  final int badge;
  final double scale;

  const _AdminUserLeading({
    required this.icon,
    required this.badge,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34 * scale,
      height: 34 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(icon, size: 22 * scale, color: AppColors.primary),
          ),
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                  minWidth: 17 * scale,
                  minHeight: 17 * scale,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
