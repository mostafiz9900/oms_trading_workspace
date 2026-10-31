import 'dart:async';


import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/values/space.dart';
import '../../../home/controllers/home_controller.dart';
import '/app/data/models/marquee_holder.dart';
import 'package:flutter/material.dart';


class ClickableMarqueeTextList extends StatefulWidget {
  final HomeController homeCon;

  const ClickableMarqueeTextList({super.key, required this.homeCon});

  @override
  State<ClickableMarqueeTextList> createState() => _ClickableMarqueeTextListState();
}

class _ClickableMarqueeTextListState extends State<ClickableMarqueeTextList> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  Timer? _scrollTimer;
  bool _isScrolling = true;
  bool _onScreen = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pause the auto-scroll while the Market tab is hidden or another page
    // covers it (the timer used to run 33 times a second all session); it
    // resumes from the same spot when visible again.
    final onScreen = Visibility.of(context) && TickerMode.valuesOf(context).enabled;
    if (onScreen == _onScreen) return;
    _onScreen = onScreen;
    if (!onScreen) {
      _scrollTimer?.cancel();
    } else if (_isScrolling) {
      _autoScroll();
    }
  }

  void _autoScroll() async {
    _isScrolling = true;
    _scrollTimer?.cancel();
    if (!_onScreen) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      // ✅ Ensure controller is attached
      if (!_scrollController.hasClients || !_isScrolling) return;

      final position = _scrollController.position;
      if (!position.hasPixels) return; // safety check

      try {
        if (_scrollController.offset >= position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollController.offset + 1);
        }
      } catch (e) {
        debugPrint("Auto-scroll error: $e");
      }
    });
  }

  void _onTextTap(MarqueeHolder marqueeHolder) {
    toggleScroll();
  }

  void stopScroll() {
    _isScrolling = false;
    _scrollTimer?.cancel();
  }

  void toggleScroll() {
    if (_isScrolling) {
      stopScroll();
    } else {
      _autoScroll();
    }
    setState(() {}); // Refresh button icon
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(MarqueeHolder marqueeHolder) {
    return GestureDetector(
      onTap: () => _onTextTap(marqueeHolder),
      child: Container(
        color: context.bgColor,
        padding: const .symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            Icon(
              marqueeHolder.status == "Up"
                  ? Icons.arrow_upward_sharp
                  : marqueeHolder.status == "Down"
                  ? Icons.arrow_downward_sharp
                  : Icons.swap_vert,

              color: marqueeHolder.status == "Up"
                  ? Colors.green
                  : marqueeHolder.status == "Down"
                  ? Colors.redAccent
                  : context.textColor,
              size: 20,
            ),
            AppSpace.spaceW2,
            Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                Text(
                  marqueeHolder.shortName ?? "",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textColor),
                ),

                Text(
                  marqueeHolder.chg?.toStringAsFixed(2) ?? "0",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForValue('${marqueeHolder.chg ?? 0.0}'),
                  ),
                ),
              ],
            ),
            AppSpace.spaceW6,
            Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                Text(
                  marqueeHolder.last?.toStringAsFixed(2) ?? "0",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForValue('${marqueeHolder.chg ?? 0.0}'),
                    //     ? Colors.green
                    //     : marqueeHolder.status == "Down"
                    //     ? Colors.redAccent
                  ),
                ),
                Text(
                  '${marqueeHolder.d?.toStringAsFixed(2) ?? "0"}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getColorForValue('${marqueeHolder.d ?? 0.0}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForValue(String value) {

    // Handle "+" and "-" signs explicitly
    if (value.startsWith('+')) {
      return Colors.green;
    }
    if (value.startsWith('-')) {
      return Colors.red;
    }

    // Try to parse the value as a double
    double? numValue = double.tryParse(value);
    if (numValue != null) {
      // Handle the zero case separately if needed
      if (numValue > 0) {
        return Colors.green;
      } else if (numValue < 0) {
        return Colors.red;
      } else {
        // Handle exactly 0 (zero) as a neutral case
        return Colors.grey.shade400;
      }
    }

    // Fallback for invalid values (not numeric and not a + or -)
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return widget.homeCon.shownMarket.marqueeList == [] || widget.homeCon.shownMarket.marqueeList.isEmpty
        ? SizedBox.shrink()
        : RepaintBoundary(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.homeCon.shownMarket.marqueeList.length,
                // marqueeList is kept sorted by shortName in the controller.
                itemBuilder: (_, index) => _buildItem(widget.homeCon.shownMarket.marqueeList[index]),
              ),
            ),
          );
  }
}
