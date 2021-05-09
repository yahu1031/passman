import 'package:flutter/material.dart';
import 'package:passman/platform/mobile/components/bottom_nav/nav_items.dart';

typedef ItemBuilder = Widget Function(
    BuildContext context, FloatingNavbarItem items);

class FloatingNavbar extends StatefulWidget {
  FloatingNavbar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    ItemBuilder? itemBuilder,
    this.backgroundColor = Colors.black,
    this.selectedBackgroundColor = Colors.white,
    this.selectedItemColor = Colors.black,
    this.iconSize = 24.0,
    this.fontSize = 11.0,
    this.borderRadius = 25,
    this.itemBorderRadius = 8,
    this.unselectedItemColor = Colors.black,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.padding = const EdgeInsets.only(bottom: 8, top: 8),
    this.width = double.infinity,
  })  : assert(items.length > 1),
        assert(items.length <= 5),
        assert(currentIndex <= items.length),
        assert(width > 50),
        itemBuilder = itemBuilder ??
            _defaultItemBuilder(
              unselectedItemColor: unselectedItemColor,
              selectedItemColor: selectedItemColor,
              borderRadius: borderRadius,
              fontSize: fontSize,
              backgroundColor: backgroundColor,
              currentIndex: currentIndex,
              iconSize: iconSize,
              itemBorderRadius: itemBorderRadius,
              items: items,
              onTap: onTap,
              selectedBackgroundColor: selectedBackgroundColor,
            ),
        super(key: key);
  final List<FloatingNavbarItem> items;
  final int currentIndex;
  final void Function(int val) onTap;
  final Color selectedBackgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color backgroundColor;
  final double fontSize;
  final double iconSize;
  final double itemBorderRadius;
  final double borderRadius;
  final ItemBuilder itemBuilder;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double width;
  @override
  _FloatingNavbarState createState() => _FloatingNavbarState();
}

class _FloatingNavbarState extends State<FloatingNavbar> {
  List<FloatingNavbarItem> get items => widget.items;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: widget.margin,
        child: AnimatedContainer(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: widget.backgroundColor,
          ),
          width: widget.width,
          duration: const Duration(milliseconds: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: items.map((FloatingNavbarItem f) {
                return widget.itemBuilder(context, f);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

ItemBuilder _defaultItemBuilder({
  Function(int val)? onTap,
  List<FloatingNavbarItem>? items,
  int? currentIndex,
  Color? selectedBackgroundColor,
  Color? selectedItemColor,
  Color? unselectedItemColor,
  Color? backgroundColor,
  double? fontSize,
  double? iconSize,
  double? itemBorderRadius,
  double? borderRadius,
}) {
  return (BuildContext context, FloatingNavbarItem item) => Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
              color: currentIndex == items!.indexOf(item)
                  ? selectedBackgroundColor
                  : backgroundColor,
              borderRadius: BorderRadius.circular(itemBorderRadius!)),
          child: InkWell(
            onTap: () {
              onTap!(items.indexOf(item));
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              //max-width for each item
              //24 is the padding from left and right
              width: MediaQuery.of(context).size.width *
                      (100 / (items.length * 100)) -
                  24,
              padding: const EdgeInsets.all(4),
              child: Icon(
                item.icon,
                color: currentIndex == items.indexOf(item)
                    ? selectedItemColor
                    : unselectedItemColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      );
}
