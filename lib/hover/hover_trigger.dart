import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stats_analyzer/hover/hover_card.dart';
import 'package:stats_analyzer/hover/hover_config.dart';

class HoverTrigger<T> extends StatefulWidget {
  final Widget child;
  final T data;
  final HoverCardBuilder<T> builder;
  final VoidCallback? onTap;
  final Duration delay;

  const HoverTrigger({
    super.key,
    required this.child,
    required this.data,
    required this.builder,
    this.onTap,
    this.delay = HoverConfig.hoverDelay,
  });

  @override
  State<HoverTrigger<T>> createState() => _HoverTriggerState<T>();
}

class _HoverTriggerState<T> extends State<HoverTrigger<T>> {
  Timer? _showTimer;
  Timer? _hideTimer;
  OverlayEntry? _overlayEntry;
  final GlobalKey _childKey = GlobalKey();
  bool _isHovering = false;

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    if (isHovering == _isHovering) return;
    _isHovering = isHovering;

    if (isHovering) {
      _hideTimer?.cancel();
      _showTimer?.cancel();
      _showTimer = Timer(widget.delay, _showOverlay);
    } else {
      _showTimer?.cancel();
      _hideTimer?.cancel();
      _hideTimer = Timer(HoverConfig.fadeOutDelay, _removeOverlay);
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    _removeOverlay();
    final renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => HoverCard(
        data: widget.data,
        builder: widget.builder,
        anchorOffset: Offset(offset.dx, offset.dy + size.height),
        onTap: widget.onTap,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: _childKey,
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}
