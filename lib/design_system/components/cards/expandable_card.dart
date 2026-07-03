import 'package:flutter/material.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';
import 'package:stats_analyzer/design_system/tokens/animation.dart';

class ExpandableCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? collapsedChild;
  final bool initiallyExpanded;
  final Widget? headerTrailing;

  const ExpandableCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.collapsedChild,
    this.initiallyExpanded = false,
    this.headerTrailing,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: DSColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: DSColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: DSTypography.headingSM.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: DSTypography.caption,
                          ),
                      ],
                    ),
                  ),
                  if (widget.headerTrailing != null) widget.headerTrailing!,
                  AnimatedRotation(
                    duration: DSAnimation.medium,
                    turns: _expanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: DSColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            duration: DSAnimation.medium,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.lg,
                0,
                DSSpacing.lg,
                DSSpacing.lg,
              ),
              child: widget.child,
            ),
            crossFadeState: _expanded 
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}
