import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SavedListSkeleton extends StatelessWidget {
  const SavedListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: const [
              Expanded(child: _ShimmerBar(widthFactor: 0.2)),
              SizedBox(width: 16),
              Expanded(child: _ShimmerBar(widthFactor: 0.25)),
              SizedBox(width: 16),
              Expanded(child: _ShimmerBar(widthFactor: 0.3)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoading(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: _SavedListTileSkeleton(),
                  ),
                  const SizedBox(width: 16),
                  const ShimmerLoading(
                    width: 32,
                    height: 32,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ],
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: itemCount,
          ),
        ),
      ],
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    required this.widthFactor,
  });

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: const ShimmerLoading(
        width: double.infinity,
        height: 12,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}

class _SavedListTileSkeleton extends StatelessWidget {
  const _SavedListTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ShimmerLoading(
          width: double.infinity,
          height: 16,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        SizedBox(height: 8),
        ShimmerLoading(
          width: 120,
          height: 12,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ],
    );
  }
}
