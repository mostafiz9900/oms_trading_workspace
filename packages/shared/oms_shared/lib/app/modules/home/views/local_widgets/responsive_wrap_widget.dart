import 'package:flutter/material.dart';

/// ResponsiveWrap: fills width, keeps `spacing` between items,
/// auto computes itemsPerRow based on minItemWidth (and maxItemWidth optional).

class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  /// the base minimum in px (hard floor). effective min = max(minItemWidth, totalWidth * minFraction)
  final double minItemWidth;

  /// hard cap for item width (can be large)
  final double maxItemWidth;

  /// fraction of total width used to compute dynamic min (e.g. 0.12 => 12% of screen)
  final double minFraction;

  /// fraction of total width used to compute dynamic max (e.g. 0.32 => 32% of screen)
  final double maxFraction;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 6,
    this.runSpacing = 10,
    this.minItemWidth = 50, // your requested floor
    this.maxItemWidth = 460,
    this.minFraction = 0.12, // 12% of width at least
    this.maxFraction = 0.32, // max ~32% of width
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        if (totalWidth.isInfinite || totalWidth <= 0) {
          return Wrap(spacing: spacing, runSpacing: runSpacing, children: children);
        }

        // compute effective min/max item width based on screen width
        final effectiveMin = (totalWidth * minFraction).clamp(minItemWidth, double.infinity);
        final effectiveMax = (totalWidth * maxFraction).clamp(0, maxItemWidth);

        // find the maximum possible items per row that still respect effectiveMin
        int maxPossible = ((totalWidth + spacing) / (effectiveMin + spacing)).floor();
        maxPossible = maxPossible.clamp(1, children.length);

        // choose itemsPerRow = maxPossible by default
        int itemsPerRow = maxPossible;

        // compute itemWidth for this itemsPerRow
        double? itemWidth = (totalWidth - spacing * (itemsPerRow - 1)) / itemsPerRow;

        // If computed itemWidth is larger than effectiveMax, try increasing itemsPerRow (if possible)
        if (itemWidth > effectiveMax) {
          final alt = ((totalWidth + spacing) / (effectiveMax + spacing)).floor();
          final newItemsPerRow = alt.clamp(1, children.length);
          if (newItemsPerRow > itemsPerRow) {
            itemsPerRow = newItemsPerRow;
            itemWidth = (totalWidth - spacing * (itemsPerRow - 1)) / itemsPerRow;
          } else {
            itemWidth = itemWidth.clamp(effectiveMin, effectiveMax).toDouble();
          }
        }

        // final clamp to safe bounds
        itemWidth = itemWidth.clamp(effectiveMin, effectiveMax).toDouble();

        // If itemWidth still below effectiveMin (happens on tiny screens), reduce itemsPerRow progressively
        while (itemWidth! < effectiveMin && itemsPerRow > 1) {
          itemsPerRow = (itemsPerRow - 1);
          itemWidth = (totalWidth - spacing * (itemsPerRow - 1)) / itemsPerRow;
        }

        // ensure final clamping
        itemWidth = itemWidth.clamp(effectiveMin, effectiveMax).toDouble();

        final wrapped = children.map((w) => SizedBox(width: itemWidth, child: w)).toList();

        return Wrap(spacing: spacing, runSpacing: runSpacing, children: wrapped);
      },
    );
  }
}

class BetterResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  /// একটি আইটেম সর্বনিম্ন কতটুকু চওড়া হতে পারবে (যেমন: 150)
  final double minItemWidth;

  /// একটি আইটেম সর্বোচ্চ কতটুকু চওড়া হতে পারবে (Optional)
  final double maxItemWidth;

  /// লাস্ট লাইনে আইটেমগুলো কীভাবে অ্যালাইন হবে (Left, Center, Right)
  final WrapAlignment alignment;

  const BetterResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 11,
    this.runSpacing = 10,
    this.minItemWidth = 150, // স্ট্যান্ডার্ড একটি সাইজ
    this.maxItemWidth = 400,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        if (totalWidth.isInfinite || totalWidth <= 0) {
          return Wrap(spacing: spacing, runSpacing: runSpacing, children: children);
        }

        // ১. এক লাইনে সর্বোচ্চ কয়টি আইটেম ধরবে তা বের করা
        int itemsPerRow = (totalWidth + spacing) ~/ (minItemWidth + spacing);
        if (itemsPerRow == 0) itemsPerRow = 1; // স্ক্রিন খুব ছোট হলেও অন্তত ১টি দেখাবে

        // ২. স্ক্রিনের জায়গা অনুযায়ী প্রতিটি আইটেমের পারফেক্ট Width বের করা
        double itemWidth = (totalWidth - (spacing * (itemsPerRow - 1))) / itemsPerRow;

        // ৩. যদি আইটেম সাইজ ম্যাক্সিমাম সাইজের চেয়ে বড় হয়ে যায়, তবে লিমিট করে দেওয়া
        if (itemWidth > maxItemWidth) {
          itemWidth = maxItemWidth;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          alignment: alignment, // Center দিলে বড় স্ক্রিনে দেখতে ভালো লাগে
          children: children.map((w) => SizedBox(width: itemWidth, child: w)).toList(),
        );
      },
    );
  }
}
