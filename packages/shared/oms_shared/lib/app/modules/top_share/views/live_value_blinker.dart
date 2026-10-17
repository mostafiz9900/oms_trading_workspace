import 'package:flutter/material.dart';

class LiveProBlinker extends StatefulWidget {
  final double trackValue;
  final Widget child;
  final Color defaultColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  const LiveProBlinker({
    super.key,
    required this.trackValue,
    required this.child,
    this.defaultColor = Colors.transparent,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    this.borderRadius,
  });

  @override
  State<LiveProBlinker> createState() => _LiveProBlinkerState();
}

class _LiveProBlinkerState extends State<LiveProBlinker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // 🕒 প্রফেশনাল স্মুথনেসের জন্য 400ms ডিউরেশন বেস্ট
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _colorAnimation = AlwaysStoppedAnimation(widget.defaultColor);
  }

  @override
  void didUpdateWidget(LiveProBlinker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.trackValue != oldWidget.trackValue) {
      final bool isUp = widget.trackValue > oldWidget.trackValue;
      final Color targetColor;

      if (widget.defaultColor == Colors.transparent) {
        targetColor = isUp
            ? const Color(0xFF00C853).withAlpha(102) // Vivid Green
            : const Color(0xFFD50000).withAlpha(102); // Vivid Red
      } else {
        // ⚪ % বক্সের জন্য স্ট্যান্ডার্ড সাদা ফ্ল্যাশ
        targetColor = Colors.white.withAlpha(153);
      }

      // 🚀 ২. Organic Animation: easeOutQuad দিলে ব্লিংকটা হুট করে নিভে না গিয়ে খুব স্মুথলি ফেড আউট হয়
      _colorAnimation = ColorTween(
        begin: targetColor,
        end: widget.defaultColor,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

      _controller.forward(from: 0.0);
    }
    // যদি % চেঞ্জ পজিটিভ থেকে নেগেটিভ হয়, তবে ডিফল্ট কালার ইনস্ট্যান্ট চেঞ্জ হবে
    else if (widget.defaultColor != oldWidget.defaultColor) {
      _colorAnimation = AlwaysStoppedAnimation(widget.defaultColor);
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // 🛡️ Memory Leak Prevented!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      // 🚀 ৩. MASSIVE PERFORMANCE BOOST: child প্রপার্টি এখানে পাস করা হয়েছে
      child: widget.child,
      builder: (context, cachedChild) {
        // Container এর বদলে DecoratedBox + Padding ব্যবহার করা হয়েছে, যা ফ্লাটার ইঞ্জিনে আরও লাইটওয়েট!
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          ),
          child: Padding(
            padding: widget.padding,
            child: cachedChild, // 🚀 এটি রিবিল্ড হবে না!
          ),
        );
      },
    );
  }
}
