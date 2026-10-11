import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../app_pkg.dart';

class OrderTypeDropdownListWidget extends ConsumerWidget {
  const OrderTypeDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.selectedValueNotifier,
    this.isShowTitle = true,
    this.hintText,
    this.height = 46.0, // ১. ডায়নামিক হাইট প্যারামিটার যুক্ত করা হলো
  });

  final ValueChanged<String?> valueChanged;
  final ValueNotifier<String?> selectedValueNotifier;
  final bool isShowTitle;
  final String? hintText;
  final double height; // হাইট ভ্যারিয়েবল

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // List-টিকে স্ট্রংলি টাইপ করা হলো
    final List<String> result = ref.watch(orderTypeProvider);

    return Container(
      // Container থেকে ফিক্সড হাইট সরিয়ে দেওয়া হয়েছে
      decoration: BoxDecoration(
        color: context.tapBg,
        borderRadius: BorderRadius.circular(0), // আপনার দেওয়া 0 রেডিয়াস রাখা হয়েছে
      ),
      // v3.1.0 এ valueListenable না থাকায় পুরো ড্রপডাউনকে ValueListenableBuilder দিয়ে র‍্যাপ করা হয়েছে
      child: ValueListenableBuilder<String?>(
        valueListenable: selectedValueNotifier,
        builder: (context, selectedValue, _) {
          // Safety Check
          final String? safeValue = result.contains(selectedValue) ? selectedValue : null;

          return DropdownButton2<String>(
            isExpanded: true,
            underline: const SizedBox.shrink(),

            // ২. হাইট কমালেও Hint টেক্সট সেন্টারে রাখার জন্য Align ব্যবহার
            hint: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hintText ?? 'Order Type',
                style: TextStyle(fontSize: 14, color: context.textColor.withAlpha((0.50 * 255).toInt())),
              ),
            ),

            // ৩. হাইট কমালেও Selected Item সেন্টারে রাখার জন্য Align ব্যবহার
            selectedItemBuilder: (BuildContext context) {
              return result.map<Widget>((String item) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: context.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList();
            },

            items: result.map<DropdownItem<String>>((String item) {
              final isSelected = safeValue == item;
              return DropdownItem<String>(
                value: item,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blue : context.textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                  ],
                ),
              );
            }).toList(),

            // valueListenable এর পরিবর্তে সরাসরি value দেওয়া হয়েছে
            valueListenable: selectedValueNotifier,
            onChanged: (val) {
              selectedValueNotifier.value = val;
              valueChanged(val);
            },

            // ৪. প্যারামিটার থেকে পাওয়া হাইট এখানে সেট করা হলো
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: height,
              width: double.infinity,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              offset: const Offset(0, 5),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
          );
        },
      ),
    );
  }
}

class OrderTypeDropdownListWidgetOld extends ConsumerWidget {
  const OrderTypeDropdownListWidgetOld({
    super.key,
    required this.valueChanged,
    required this.selectedValueNotifier,
    this.isShowTitle = true,
    this.hintText,
  });

  final ValueChanged<String?> valueChanged;
  final ValueNotifier<String?> selectedValueNotifier;
  final bool isShowTitle;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(orderTypeProvider);

    return Container(
      height: AppDimens.space46,
      decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(0)),
      child: DropdownButton2<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: Text(
          hintText ?? 'Order Type',
          style: TextStyle(fontSize: 14, color: context.textColor.withAlpha((0.50 * 255).toInt())),
        ),
        // সিলেক্টেড আইটেমের সুন্দর ভিউ
        selectedItemBuilder: (context) {
          return result.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: context.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList();
        },
        // লিস্ট আইটেম এবং চেক মার্ক
        items: result.map((item) {
          return DropdownItem<String>(
            value: item,
            child: ValueListenableBuilder<String?>(
              valueListenable: selectedValueNotifier,
              builder: (context, selectedValue, _) {
                final isSelected = selectedValue == item;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blue : context.textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                  ],
                );
              },
            ),
          );
        }).toList(),
        valueListenable: selectedValueNotifier,
        onChanged: (val) {
          selectedValueNotifier.value = val;
          valueChanged(val);
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: double.infinity,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          offset: const Offset(0, 5),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
      ),
    );
  }
}

class TypeDropdownListWidget extends ConsumerWidget {
  const TypeDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.value,
    this.isShowTitle = true,
    this.hintText,
  });

  final ValueChanged<String?> valueChanged;
  final String? value;
  final bool isShowTitle;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var result = ref.watch(typeProvider);
    // সিলেকশন আপডেট ট্র্যাক করার জন্য ভ্যালু নোটিফায়ার
    final selectedNotifier = ValueNotifier<String?>(value);

    return Container(
      height: AppDimens.space46,
      decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          underline: const SizedBox.shrink(),
          hint: Text(
            hintText ?? 'Type',
            style: TextStyle(fontSize: 14, color: context.textColor.withAlpha((0.50 * 255).toInt())),
          ),

          // সিলেক্টেড আইটেমের কাস্টম স্টাইল
          selectedItemBuilder: (context) {
            return result.map((item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: context.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },

          // আইটেম এবং চেক মার্ক লজিক
          items: result.map((item) {
            return DropdownItem<String>(
              value: item,
              child: ValueListenableBuilder<String?>(
                valueListenable: selectedNotifier,
                builder: (context, selectedValue, _) {
                  final isSelected = selectedValue == item;
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.blue : context.textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                    ],
                  );
                },
              ),
            );
          }).toList(),

          valueListenable: selectedNotifier,
          onChanged: (val) {
            selectedNotifier.value = val;
            valueChanged(val);
          },

          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: double.infinity,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all(6),
              thumbVisibility: WidgetStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
        ),
      ),
    );
  }
}

class ValidityDropdownListWidgetOld extends ConsumerWidget {
  const ValidityDropdownListWidgetOld({
    super.key,
    required this.valueChanged,
    required this.value,
    this.isShowTitle = true,
    this.hintText,
  });

  final ValueChanged<String?> valueChanged;
  final String? value;
  final bool isShowTitle;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var result = ref.watch(validityProvider);

    return Container(
      height: AppDimens.space46,
      decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton2<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: Text(
          hintText ?? 'Validity',
          style: TextStyle(fontSize: 14, color: context.textColor.withValues(alpha: 0.50)),
        ),

        // সিলেক্টেড ভ্যালু বোল্ড করে দেখানোর জন্য
        selectedItemBuilder: (context) {
          return result.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: context.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList();
        },

        // আইটেম এবং চেকমার্ক লজিক
        items: result.map((item) {
          final isSelected = value == item;
          return DropdownItem<String>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.blue : context.textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 18),
              ],
            ),
          );
        }).toList(),

        valueListenable: ValueNotifier<String?>(value),
        onChanged: valueChanged,
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: double.infinity,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          overlayColor: WidgetStateProperty.all(Colors.blue.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}

class ValidityDropdownListWidget extends ConsumerWidget {
  const ValidityDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.value,
    this.isShowTitle = true,
    this.hintText,
    this.height = 46.0, // প্যারামিটার হিসেবে হাইট নেওয়া হলো
  });

  final ValueChanged<String?> valueChanged;
  final String? value;
  final bool isShowTitle;
  final String? hintText;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // List-টিকে স্ট্রংলি টাইপ করা হলো যাতে value এবং items-এ টাইপ এরর না আসে
    final List<String> result = ref.watch(validityProvider);
    final String? safeValue = result.contains(value) ? value : null;

    return Container(
      decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton2<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),

        // হাইট কমালেও হিন্ট টেক্সট সেন্টারে রাখার জন্য Align ব্যবহার
        hint: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            hintText ?? 'Validity',
            style: TextStyle(fontSize: 14, color: context.textColor.withValues(alpha: 0.50)),
          ),
        ),

        // হাইট কমালেও সিলেক্টেড টেক্সট সেন্টারে রাখার জন্য Align ব্যবহার
        selectedItemBuilder: (BuildContext context) {
          return result.map<Widget>((String item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14, color: context.textColor, fontWeight: FontWeight.w500),
              ),
            );
          }).toList();
        },

        // DropdownMenuItem-এর বদলে v3.1.0 অনুযায়ী DropdownItem ব্যবহার করা হলো
        items: result.map<DropdownItem<String>>((String item) {
          final isSelected = safeValue == item;
          return DropdownItem<String>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.blue : context.textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 18),
              ],
            ),
          );
        }).toList(),

        // Value এবং OnChanged
        valueListenable: ValueNotifier<String?>(value),
        onChanged: valueChanged,

        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: height,
          width: double.infinity,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          overlayColor: WidgetStateProperty.all(Colors.blue.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}

class WatchDropdownListWidget extends ConsumerWidget {
  final searchController = TextEditingController();
  WatchDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.value,
    this.isShowTitle = true,
    this.hintText,
    required this.items,
  });
  final List<String?> items;
  final ValueChanged<String?> valueChanged;
  final String? value;
  final bool isShowTitle;
  final String? hintText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const .symmetric(vertical: 4),
        height: AppDimens.space50,
        decoration: BoxDecoration(color: HexColor("#EBF2FC")),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text('Search..', style: TextStyle(fontSize: 14, color: context.textColor.alphaSafe(0.50))),
            items: items
                .map(
                  (item) => DropdownItem(
                    value: item,
                    child: Text(item ?? "", style: TextStyle(fontSize: 14, color: context.textColor.a50())),
                  ),
                )
                .toList(),
            valueListenable: ValueNotifier<String?>(value),
            onChanged: valueChanged,
            buttonStyleData: ButtonStyleData(padding: .symmetric(horizontal: 16), height: 40, width: Get.width * 0.50),
            dropdownStyleData: DropdownStyleData(maxHeight: Get.height * 0.70),
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchBarWidgetHeight: 50,
              searchBarWidget: Padding(
                padding: const EdgeInsets.all(6),
                child: CustomEditTextFormField(
                  controller: searchController,
                  onChanged: (value) {
                    printLog('vlu:: $value');
                  },
                ),
              ),
              searchMatchFn: (item, searchValue) {
                // ✅ Make sure item.value is a String and can be searched
                final val = item.value?.toString().toLowerCase() ?? '';
                return val.contains(searchValue.toLowerCase());
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFilterDropdown extends StatelessWidget {
  final String title;
  final String? selectedValue;
  final List<String> items;
  final Function(String) onSelected;

  const CustomFilterDropdown({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      offset: const Offset(0, 45),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5, // স্ক্রিনের ৪০% হাইট পর্যন্ত হবে
        minWidth: 150,
      ),
      onSelected: onSelected,
      itemBuilder: (context) => items.map((item) {
        bool isSelected = (item == selectedValue);
        return PopupMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: Get.textTheme.bodyMedium?.copyWith(color: isSelected ? Colors.blue : Colors.black87),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        // বাটনের ভেতরে Flexible ব্যবহার করা যাতে টেক্সট বড় হলেও পিক্সেল এরর না দেয়
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                selectedValue ?? title,
                style: const TextStyle(fontSize: 14, color: Colors.blue),
                overflow: TextOverflow.ellipsis, // বড় টেক্সট হলে ডট ডট দেখাবে
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
/* 

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../app_pkg.dart';

class OrderTypeDropdownListWidget extends ConsumerWidget {
  const OrderTypeDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.selectedValueNotifier,
    this.isShowTitle = true,
    this.hintText,
  });

  final ValueChanged<String?> valueChanged;
  final ValueNotifier<String?> selectedValueNotifier;
  final bool isShowTitle;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(orderTypeProvider);
    final isDark = context.isDark;

    return Container(
      height: AppDimens.space46,
      decoration: BoxDecoration(
        color: context.tapBg, 
        borderRadius: BorderRadius.circular(8) // 🚀 বর্ডার রেডিয়াশ 0 থেকে 8 করা হলো (M3 Standard)
      ),
      child: DropdownButton2<String>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: Text(
          hintText ?? 'Order Type',
          style: TextStyle(
            fontSize: 14, 
            color: context.textColor?.withValues(alpha: 0.50) // 🚀 Deprecated API Fixed
          ),
        ),
        selectedItemBuilder: (context) {
          return result.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: context.textColor,
                  fontWeight: FontWeight.w600, // 🚀 সিলেক্টেড টেক্সট আরেকটু বোল্ড করা হলো
                ),
              ),
            );
          }).toList();
        },
        items: result.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: ValueListenableBuilder<String?>(
              valueListenable: selectedValueNotifier,
              builder: (context, selectedValue, _) {
                final isSelected = selectedValue == item;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blueAccent : context.textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.blueAccent, size: 18),
                  ],
                );
              },
            ),
          );
        }).toList(),
        value: selectedValueNotifier.value,
        onChanged: (val) {
          if (val != null) {
            selectedValueNotifier.value = val;
            valueChanged(val);
          }
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: double.infinity,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 250, // 🚀 লিস্ট স্ক্রলিং এর জন্য হাইট বাড়ানো হলো
          offset: const Offset(0, 5),
          decoration: BoxDecoration(
            color: context.theme.cardColor, // 🚀 Dark Mode Supported
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08), 
                blurRadius: 8, 
                offset: const Offset(0, 4)
              )
            ],
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
      ),
    );
  }
}

class TypeDropdownListWidget extends ConsumerWidget {
  const TypeDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.value,
    this.isShowTitle = true,
    this.hintText,
  });

  final ValueChanged<String?> valueChanged;
  final String? value;
  final bool isShowTitle;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var result = ref.watch(typeProvider);

    return Container(
      height: AppDimens.space46,
      decoration: BoxDecoration(
        color: context.tapBg, 
        borderRadius: BorderRadius.circular(8)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            hintText ?? 'Type',
            style: TextStyle(fontSize: 14, color: context.textColor?.withValues(alpha: 0.50)),
          ),
          selectedItemBuilder: (context) {
            return result.map((item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: context.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList();
          },
          items: result.map((item) {
            final isSelected = value == item;
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.blueAccent : context.textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.blueAccent, size: 18),
                ],
              ),
            );
          }).toList(),
          value: value, // 🚀 Inline ValueNotifier এন্টি-প্যাটার্ন রিমুভ করা হলো
          onChanged: (val) {
            if (val != null) valueChanged(val);
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: double.infinity,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08), 
                  blurRadius: 8, 
                  offset: const Offset(0, 4)
                )
              ],
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all(6), // 🚀 WidgetStateProperty used (M3)
              thumbVisibility: WidgetStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
        ),
      ),
    );
  }
}

class ValidityDropdownListWidget extends ConsumerWidget {
  const ValidityDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.value,
    this.isShowTitle = true,
    this.hintText,
  });

  final ValueChanged<String?> valueChanged;
  final String? value;
  final bool isShowTitle;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var result = ref.watch(validityProvider);

    return Container(
      height: AppDimens.space46,
      decoration: BoxDecoration(
        color: context.tapBg, 
        borderRadius: BorderRadius.circular(8)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            hintText ?? 'Validity',
            style: TextStyle(fontSize: 14, color: context.textColor?.withValues(alpha: 0.50)),
          ),
          selectedItemBuilder: (context) {
            return result.map((item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: context.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList();
          },
          items: result.map((item) {
            final isSelected = value == item;
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.blueAccent : context.textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.blueAccent, size: 18),
                ],
              ),
            );
          }).toList(),
          value: value, 
          onChanged: valueChanged,
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            width: double.infinity,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08), 
                  blurRadius: 8, 
                  offset: const Offset(0, 4)
                ),
              ],
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            overlayColor: WidgetStateProperty.all(Colors.blueAccent.withValues(alpha: 0.1)),
          ),
        ),
      ),
    );
  }
}

class WatchDropdownListWidget extends ConsumerWidget {
  final searchController = TextEditingController();
  
  WatchDropdownListWidget({
    super.key,
    required this.valueChanged,
    required this.value,
    this.isShowTitle = true,
    this.hintText,
    required this.items,
  });

  final List<String?> items;
  final ValueChanged<String?> valueChanged;
  final String? value;
  final bool isShowTitle;
  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4), // 🚀 Syntax Error Fixed (was .symmetric)
      height: AppDimens.space50,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : HexColor("#EBF2FC"), // 🚀 Dark mode adapt
        borderRadius: BorderRadius.circular(8)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Search..', 
            style: TextStyle(fontSize: 14, color: context.textColor?.withValues(alpha: 0.50))
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item ?? "", 
                style: TextStyle(fontSize: 14, color: context.textColor)
              ),
            );
          }).toList(),
          value: value,
          onChanged: valueChanged,
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16), // 🚀 Syntax Error Fixed
            height: 40, 
            width: Get.width * 0.50
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: Get.height * 0.70,
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            )
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: searchController,
            searchBarWidgetHeight: 50,
            searchBarWidget: Padding(
              padding: const EdgeInsets.all(8),
              child: CustomEditTextFormField(
                controller: searchController,
                hintText: "Type to search...",
                onChanged: (value) {},
              ),
            ),
            searchMatchFn: (item, searchValue) {
              final val = item.value?.toString().toLowerCase() ?? '';
              return val.contains(searchValue.toLowerCase());
            },
          ),
        ),
      ),
    );
  }
}

class CustomFilterDropdown extends StatelessWidget {
  final String title;
  final String? selectedValue;
  final List<String> items;
  final Function(String) onSelected;

  const CustomFilterDropdown({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return PopupMenuButton<String>(
      color: context.theme.cardColor, // 🚀 Fixed Hardcoded White Color (Dark Mode Supported)
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 🚀 M3 Rounded corners
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5, 
        minWidth: 150,
      ),
      onSelected: onSelected,
      itemBuilder: (context) => items.map((item) {
        bool isSelected = (item == selectedValue);
        return PopupMenuItem<String>(
          value: item,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.blueAccent : context.textColor, // 🚀 Fixed Hardcoded Black87
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                ),
              ),
              if (isSelected) const Icon(Icons.check, color: Colors.blueAccent, size: 18)
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // 🚀 বয়স্কদের জন্য প্যাডিং বাড়ানো হলো
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible( // 🚀 Expanded এর বদলে Flexible দেওয়া হলো যাতে ছোট কনটেইনারেও এরর না দেয়
              child: Text(
                selectedValue ?? title,
                style: TextStyle(
                  fontSize: 14, 
                  color: selectedValue != null ? Colors.blueAccent : context.textColor,
                  fontWeight: FontWeight.w600
                ),
                overflow: TextOverflow.ellipsis, 
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

 */