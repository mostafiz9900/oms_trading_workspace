import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_pkg.dart';

class SearchDialogWidget extends StatelessWidget {
  const SearchDialogWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final homeCon = Get.find<HomeController>();
        homeCon.searchController.clear();
        // Note: You may not even need homeCon.filterItems('') here anymore
        // because we are handling the UI filtering robustly below.

        Helpers.customShowDialog(
          context,
          title: 'Search Market',
          fontSize: 16.0,
          children: const [Flexible(child: _SearchDialogContent())],
        );
      },
      child: child,
    );
  }
}

/// Extracted to StatefulWidget to properly manage Keyboard Focus
class _SearchDialogContent extends StatefulWidget {
  const _SearchDialogContent({super.key});

  @override
  State<_SearchDialogContent> createState() => _SearchDialogContentState();
}

class _SearchDialogContentState extends State<_SearchDialogContent> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeCon = Get.find<HomeController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Search Text Field ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextFormField(
            controller: homeCon.searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            cursorColor: Get.theme.primaryColor,
            decoration: InputDecoration(
              hintText: 'Search short name...',
              prefixIcon: const Icon(Icons.search, size: 22, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
                onPressed: () {
                  homeCon.searchController.clear();
                  // 🚀 এখানে id পরিবর্তন করে 'searchMarketList' দেওয়া হলো
                  homeCon.update(['searchMarketList']);
                },
                tooltip: 'Clear',
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.borderColor, width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: context.borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (value) {
              // 🚀 এখানে id পরিবর্তন করে 'searchMarketList' দেওয়া হলো
              homeCon.update(['searchMarketList']);
            },
          ),
        ),

        // --- List View ---
        Flexible(
          // 🚀 এখানে GetBuilder এর id পরিবর্তন করে 'searchMarketList' দেওয়া হলো
          child: GetBuilder<HomeController>(
            id: 'searchMarketList',
            builder: (controller) {
              final String searchText = controller.searchController.text.trim().toLowerCase();
              final Set<String> seenNames = {};

              // 1. FILTER
              List<dynamic> validItems = controller.marketListForDilog.where((item) {
                final name = item.shortName;

                if (name == null || name.isEmpty) return false;
                if (item.group != "PUBLIC" || item.board != "Main Board") return false;
                if (seenNames.contains(name)) return false;

                if (searchText.isNotEmpty && !name.toLowerCase().contains(searchText)) {
                  return false;
                }

                seenNames.add(name);
                return true;
              }).toList();

              // 2. SORTING
              if (searchText.isNotEmpty) {
                validItems.sort((a, b) {
                  final String nameA = a.shortName!.toLowerCase();
                  final String nameB = b.shortName!.toLowerCase();

                  final bool startsWithA = nameA.startsWith(searchText);
                  final bool startsWithB = nameB.startsWith(searchText);

                  if (startsWithA && !startsWithB) return -1;
                  if (!startsWithA && startsWithB) return 1;

                  return nameA.compareTo(nameB);
                });
              }

              // 3. EMPTY STATE
              if (validItems.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text("No markets found", style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              // 4. BUILD UI
              return ListView.builder(
                itemCount: validItems.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0, bottom: 16.0),
                itemBuilder: (context, index) {
                  final item = validItems[index];
                  final isEven = index % 2 == 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Material(
                      color: isEven ? context.evenColor : context.oddColor,
                      borderRadius: BorderRadius.circular(8.0),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          _focusNode.unfocus();
                          Navigator.of(context).pop();

                          if (item.orderBook != null) {
                            controller.newMarketInfo(item.orderBook!);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: item.shortName ?? "",
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    color: context.textColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: '  [${item.group}]',
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                    fontFeatures: const [FontFeature.superscripts()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
