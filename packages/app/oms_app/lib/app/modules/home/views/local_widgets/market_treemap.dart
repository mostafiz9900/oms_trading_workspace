import '/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import 'package:get/get.dart';

import 'index_value_loader.dart';

class MarketMapWidget extends StatefulWidget {
  const MarketMapWidget({super.key});

  @override
  State<MarketMapWidget> createState() => _MarketMapWidgetState();
}

class _MarketMapWidgetState extends State<MarketMapWidget> {
  String? _selectedSector;

  // =========================================================================
  // 🚀 Core Business Logic (অপরিবর্তিত)
  // =========================================================================
  double _parseChgToDouble(dynamic raw) {
    try {
      if (raw == null) return 0.0;
      if (raw is num) return raw.toDouble();
      if (raw is String) {
        var s = raw.trim();
        if (s.isEmpty) return 0.0;
        if (s.endsWith('%')) s = s.substring(0, s.length - 1).trim();
        s = s.replaceAll('\u2212', '-');
        s = s.replaceAll(',', '');
        s = s.replaceAll('\u00A0', '').trim();
        if (s.isEmpty) return 0.0;
        final d = double.tryParse(s);
        if (d != null) return d;
        final cleaned = RegExp(r'[^0-9\.\-]').allMatches(s).map((m) => m.group(0)).join();
        final d2 = double.tryParse(cleaned);
        return d2 ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  double getChgSafe(MarketModel m) {
    try {
      double parsedChg = _parseChgToDouble(m.chg);

      if (parsedChg == 0.0) {
        final double currentPrice = m.last ?? m.close ?? 0.0;
        final double refPrice = m.reference ?? 0.0;

        if (refPrice > 0 && currentPrice > 0) {
          parsedChg = ((currentPrice - refPrice) / refPrice) * 100;
        } else if (m.d != null && refPrice > 0) {
          parsedChg = (m.d! / refPrice) * 100;
        }
      }

      if (parsedChg.isNaN || parsedChg.isInfinite) return 0.0;
      return parsedChg;
    } catch (e) {
      return 0.0;
    }
  }

  List<MarketModel> _buildGroupedAndSortedSourceParsed(List<MarketModel> markets) {
    final Map<String, List<MarketModel>> groups = {};
    for (final m in markets) {
      final sec = (m.sector ?? 'Unknown').trim();
      groups.putIfAbsent(sec, () => []).add(m);
    }

    const double zeroTol = 1e-9;
    final List<MarketModel> flattened = [];

    for (final entry in groups.entries) {
      final items = List<MarketModel>.from(entry.value);
      final Map<MarketModel, int> origIdx = {};
      for (var i = 0; i < items.length; i++) {
        origIdx[items[i]] = i;
      }

      items.sort((a, b) {
        final double da = getChgSafe(a);
        final double db = getChgSafe(b);

        final bool aPos = da > zeroTol;
        final bool bPos = db > zeroTol;
        final bool aZero = da.abs() <= zeroTol;
        final bool bZero = db.abs() <= zeroTol;

        int classA = aPos ? 2 : (aZero ? 1 : 0);
        int classB = bPos ? 2 : (bZero ? 1 : 0);
        if (classA != classB) return classB - classA;

        if (classA == 2) return db.compareTo(da);
        if (classA == 1) return (origIdx[a] ?? 0).compareTo(origIdx[b] ?? 0);
        return da.compareTo(db);
      });

      flattened.addAll(items);
    }

    return flattened;
  }

  Color sectorTileColor(double? sectorValue) {
    final double c = sectorValue ?? 0.0;
    if (c > 0.005) {
      return ColorConstants.forestGreen;
    } else if (c < -0.005) {
      return ColorConstants.coralRed;
    } else {
      return ColorConstants.buttonColorLight.withOpacity(0.8);
    }
  }

  String formatChgText(double changeVal) {
    if (changeVal.abs() < 0.005) {
      return '0.00%';
    }
    final String prefix = changeVal > 0 ? '+' : '';
    return '$prefix${changeVal.toStringAsFixed(2)}%';
  }

  // =========================================================================
  // 🚀 Perfect UI: Left-Center Aligned & Fully Responsive Texts
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double responsiveHeight = (screenHeight * 0.65).clamp(400.0, 800.0);

    return GetBuilder<HomeController>(
      id: 'marketList',
      builder: (homeController) {
        if (!homeController.marketList.isNotEmpty || homeController.marketList.length < 20) {
          return MarketMapLoader(height: responsiveHeight);
        }
        final visibleList = homeController.marketList
            .where((m) => m.group == "PUBLIC" && m.board == "Main Board")
            .toList();
        if (visibleList.isEmpty) {
          return MarketMapLoader(height: responsiveHeight);
        }
        final List<MarketModel> allSortedSource = _buildGroupedAndSortedSourceParsed(visibleList);

        final List<MarketModel> displayedSource = _selectedSector == null
            ? allSortedSource
            : allSortedSource.where((m) => (m.sector ?? 'Unknown').trim() == _selectedSector).toList();

        if (displayedSource.isEmpty) {
          return SizedBox(
            height: responsiveHeight,
            width: screenWidth,
            child: Center(
              child: Text(
                'No data available for this sector',
                style: TextStyle(color: context.textColor.withOpacity(0.7), fontSize: 14),
              ),
            ),
          );
        }

        final List<double> itemWeights = [];
        double maxTurnover = 0.0;

        for (final m in displayedSource) {
          double turnover = 1.0;
          if (m.val != null && m.val! > 0) {
            turnover = m.val!;
          } else if ((m.volume ?? 0) > 0) {
            final double price = m.close ?? m.last ?? m.reference ?? 0.0;
            if (price > 0) {
              turnover = m.volume!.toDouble() * price;
            }
          }
          if (turnover.isNaN || turnover.isInfinite || turnover <= 0.0) {
            turnover = 1.0;
          }
          if (turnover > 1e15) turnover = 1e15;

          itemWeights.add(turnover);
          if (turnover > maxTurnover) maxTurnover = turnover;
        }

        final double minWeight = maxTurnover * 0.01;
        for (int i = 0; i < itemWeights.length; i++) {
          if (itemWeights[i] < minWeight) {
            itemWeights[i] = minWeight;
          }
        }

        final bool isZoomed = _selectedSector != null;

        return Container(
          constraints: BoxConstraints(minHeight: responsiveHeight, maxHeight: responsiveHeight, maxWidth: screenWidth),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: Get.theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(0)),
          child: Column(
            children: [
              // --- 1. Header Area ---
              SizedBox(
                height: 38,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: context.tapBg,
                    // borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                  child: Row(
                    children: [
                      if (isZoomed)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSector = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Get.theme.scaffoldBackgroundColor,
                              // borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: context.borderSideColor.withOpacity(0.5), width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_ios_new_rounded, color: context.textColor, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'Back',
                                  style: TextStyle(color: context.textColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isZoomed) const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isZoomed ? _selectedSector! : "Market Map Overview",
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isZoomed)
                        Row(
                          children: [
                            Icon(Icons.touch_app_rounded, size: 12, color: context.textColor.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              "Tap to zoom",
                              style: TextStyle(
                                fontSize: 10,
                                color: context.textColor.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // --- 2. Treemap Area ---
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (!constraints.hasBoundedWidth ||
                        !constraints.hasBoundedHeight ||
                        constraints.maxWidth <= 0 ||
                        constraints.maxHeight <= 0) {
                      return const SizedBox.shrink();
                    }

                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                      child: SfTreemap(
                        key: ValueKey(_selectedSector ?? 'ALL'),
                        dataCount: displayedSource.length,
                        weightValueMapper: (int index) {
                          double w = itemWeights[index];
                          if (w.isNaN || w.isInfinite || w <= 0) return 1.0;
                          return w;
                        },
                        enableDrilldown: false,
                        levels: [
                          // 🚀 Level 0: Sector Titles
                          if (!isZoomed)
                            TreemapLevel(
                              groupMapper: (int index) => (displayedSource[index].sector ?? 'Unknown'),
                              padding: EdgeInsets.zero,
                              color: const Color(0xFF141414), // 🚀 অরিজিনাল ডার্ক কালার ফিরে এসেছে
                              labelBuilder: (BuildContext context, TreemapTile tile) {
                                return IgnorePointer(
                                  child: Container(
                                    alignment: Alignment.centerLeft, // 🚀 টাইটেল একদম Left-Center ফিক্সড
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown, // 🚀 সাইজের সাথে রেস্পন্সিভ হয়ে ছোট হবে
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        tile.group.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white, // অরিজিনাল হোয়াইট টেক্সট
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                          // 🚀 Level 1: Child Tiles
                          TreemapLevel(
                            groupMapper: (int index) {
                              final m = displayedSource[index];
                              return (m.shortName?.isNotEmpty == true ? m.shortName : (m.ticker ?? 'N/A'))!;
                            },
                            padding: EdgeInsets.zero,
                            itemBuilder: (BuildContext context, TreemapTile tile) {
                              final idx = tile.indices[0];
                              final model = displayedSource[idx];
                              final Color tileBgColor = sectorTileColor(model.chg);

                              final String title = model.shortName?.isNotEmpty == true
                                  ? model.shortName!
                                  : (model.ticker ?? 'N/A');
                              final double changeVal = model.chg ?? 0.0;
                              final String chgStr = formatChgText(changeVal);

                              return GestureDetector(
                                onTap: () {
                                  if (!isZoomed) {
                                    setState(() {
                                      _selectedSector = model.sector;
                                    });
                                  } else {
                                    homeController.goBottomNabBarPage(1, model.orderBook!);
                                    homeController.loadComanyDividentEPS('${model.shortName}');
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tileBgColor,
                                    border: Border.all(color: Colors.black, width: 0.5), // Custom Border
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, tileConstraints) {
                                      if (tileConstraints.maxWidth < 15 || tileConstraints.maxHeight < 15) {
                                        return const SizedBox.shrink();
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown, // 🚀 প্রতিটি টেক্সট সাইজের সাথে নিজে থেকেই ছোট হবে
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  title,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isZoomed ? 14 : 11,
                                                  ),
                                                ),
                                                if (isZoomed || tileConstraints.maxHeight > 25)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2.0),
                                                    child: Text(
                                                      chgStr,
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.95),
                                                        fontSize: isZoomed ? 12 : 9.5,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        tooltipSettings: const TreemapTooltipSettings(color: Color(0xFF1E1E1E)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
