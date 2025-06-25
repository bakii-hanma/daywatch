import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration animationDuration;
  final Duration pauseDuration;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.style,
    this.animationDuration = const Duration(milliseconds: 3000),
    this.pauseDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _needsAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scrollController = ScrollController();

    // Animation qui va de 0 à 1 avec des pauses
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _animation.addListener(() {
      if (_needsAnimation && _scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(maxScroll * _animation.value);
      }
    });

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(widget.pauseDuration, () {
          if (mounted) {
            _controller.reset();
            Future.delayed(widget.pauseDuration, () {
              if (mounted && _needsAnimation) {
                _controller.forward();
              }
            });
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTextWidth();
    });
  }

  void _calculateTextWidth() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    _textWidth = textPainter.size.width;

    // Calculer la largeur du conteneur
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _containerWidth = renderBox.size.width;
      _needsAnimation = _textWidth > _containerWidth;

      if (_needsAnimation) {
        Future.delayed(widget.pauseDuration, () {
          if (mounted) {
            _controller.forward();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_containerWidth != constraints.maxWidth) {
            _containerWidth = constraints.maxWidth;
            _needsAnimation = _textWidth > _containerWidth;

            if (_needsAnimation && !_controller.isAnimating) {
              _controller.reset();
              Future.delayed(widget.pauseDuration, () {
                if (mounted) {
                  _controller.forward();
                }
              });
            } else if (!_needsAnimation) {
              _controller.stop();
              _controller.reset();
            }
          }
        });

        return SizedBox(
          width: constraints.maxWidth,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        );
      },
    );
  }
}
