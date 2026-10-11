import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../core/utils/extensions/app_context.dart';
import '../core/values/dimens.dart';
import '../global_provider.dart';

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
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 4, offset: const Offset(0, 2))],
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

