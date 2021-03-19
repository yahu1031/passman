import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passman/Components/pin_field_state.dart';

class PinField extends StatefulWidget {
  const PinField({
    Key? key,
    required this.fieldsCount,
    this.onSubmit,
    this.onSaved,
    this.onChanged,
    this.onTap,
    this.onClipboardFound,
    this.controller,
    this.focusNode,
    this.preFilledWidget,
    this.separatorPositions = const <int>[],
    this.separator = const SizedBox(width: 15.0),
    this.textStyle,
    this.submittedFieldDecoration,
    this.selectedFieldDecoration,
    this.followingFieldDecoration,
    this.disabledDecoration,
    this.eachFieldWidth,
    this.eachFieldHeight,
    this.fieldsAlignment = MainAxisAlignment.spaceBetween,
    this.eachFieldAlignment = Alignment.center,
    this.eachFieldMargin,
    this.eachFieldPadding,
    this.eachFieldConstraints =
        const BoxConstraints(minHeight: 40.0, minWidth: 40.0),
    this.inputDecoration = const InputDecoration(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      counterText: '',
    ),
    this.animationCurve = Curves.linear,
    this.animationDuration = const Duration(milliseconds: 160),
    this.pinAnimationType = PinAnimationType.slide,
    this.slideTransitionBeginOffset,
    this.enabled = true,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.withCursor = false,
    this.cursor,
    this.keyboardAppearance,
    this.inputFormatters,
    this.validator,
    this.keyboardType = TextInputType.number,
    this.obscureText,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.toolbarOptions,
    this.mainAxisSize = MainAxisSize.max,
  })  : assert(fieldsCount > 0),
        super(key: key);

  final int fieldsCount;
  final ValueChanged<String>? onSubmit;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String?>? onClipboardFound;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? preFilledWidget;
  final List<int> separatorPositions;
  final Widget separator;
  final TextStyle? textStyle;
  final BoxDecoration? submittedFieldDecoration;
  final BoxDecoration? selectedFieldDecoration;
  final BoxDecoration? followingFieldDecoration;
  final BoxDecoration? disabledDecoration;
  final double? eachFieldWidth;
  final double? eachFieldHeight;
  final MainAxisAlignment fieldsAlignment;
  final AlignmentGeometry eachFieldAlignment;
  final EdgeInsetsGeometry? eachFieldMargin;
  final EdgeInsetsGeometry? eachFieldPadding;
  final BoxConstraints eachFieldConstraints;
  final InputDecoration inputDecoration;
  final Curve animationCurve;
  final Duration animationDuration;
  final PinAnimationType pinAnimationType;
  final Offset? slideTransitionBeginOffset;
  final bool enabled;
  final bool autofocus;
  final AutovalidateMode autovalidateMode;
  final bool withCursor;
  final Widget? cursor;
  final Brightness? keyboardAppearance;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final String? obscureText;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ToolbarOptions? toolbarOptions;
  final MainAxisSize mainAxisSize;

  @override
  PinFieldState createState() => PinFieldState();
}

enum PinAnimationType {
  none,
  scale,
  fade,
  slide,
  rotation,
}
