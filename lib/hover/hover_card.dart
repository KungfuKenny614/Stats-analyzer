import 'package:flutter/material.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/hover/hover_config.dart';

typedef HoverCardBuilder<T> = Widget Function(BuildContext context, T data);

class HoverCard<T> extends StatelessWidget {
  final T data;
  final HoverCardBuilder<T> builder;
  final Offset anchorOffset;
  final VoidCallback? onTap;

  const HoverCard({
    super.key,
    required this.data,
    required this.builder,
    required this.anchorOffset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: anchorOffset.dx.clamp(0.0, MediaQuery.of(context).size.width - HoverConfig.maxWidth),
      top: anchorOffset.dy,
      child: Material(
        color: Colors.transparent,
        child: FractionalTranslation(
          translation: const Offset(0, 0.02),
          child: AnimatedContainer(
            duration: HoverConfig.animationDuration,
            curve: Curves.easeOut,
            width: HoverConfig.maxWidth.clamp(
              HoverConfig.minWidth,
              MediaQuery.of(context).size.width - 32,
            ),
            constraints: BoxConstraints(
              maxHeight: HoverConfig.maxHeight,
            ),
            decoration: BoxDecoration(
              color: DSColors.deSurface,
              borderRadius: BorderRadius.circular(HoverConfig.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: DSColors.deBorder,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HoverConfig.borderRadius),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    builder(context, data),
                    if (onTap != null)
                      Divider(
                        height: 16,
                        thickness: 0.5,
                        color: DSColors.deBorder,
                      ),
                    if (onTap != null)
                      GestureDetector(
                        onTap: onTap,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'View Details →',
                              style: TextStyle(
                                color: DSColors.deAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
