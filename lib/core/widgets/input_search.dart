import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/constants/constants.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/ts.dart';

class InputSearch extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final String hintText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool enableInteractiveSelection;
  final Color? textColor;

  const InputSearch({
    Key? key,
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    this.hintText = '',
    this.textInputAction,
    this.keyboardType,
    this.enableInteractiveSelection = true,
    this.textColor,
  }) : super(key: key);

  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  Color get _textColor {
    return widget.textColor != null ? widget.textColor! : Theme.of(context).primaryColor;
  }

  void _onChanged(String value) {
    TextSelection prevSelection = widget.controller?.selection ?? const TextSelection.collapsed(offset: 0);
    widget.controller?.selection = prevSelection;

    widget.onChanged(value);
    setState(() {});
  }

  /// Without IconButton wrapper it rendered not correctly
  Widget _wPrefix() {
    return IconButton(
      onPressed: null,
      icon: SvgPicture.asset(
        'assets/chat_icons/search.svg',
        width: kBaseSize,
        height: kBaseSize,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _wSuffix() {
    if (widget.controller?.text.isNotEmpty == true) {
      return IconButton(
        constraints: const BoxConstraints(),
        onPressed: () {
          widget.controller?.clear();
          _onChanged('');
        },
        iconSize: kBaseSize,
        color: Config.grayG2Color,
        icon: const Icon(Icons.cancel),
      );
    }

    return const SizedBox.shrink();
  }

  InputBorder get _border {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(width: 0, style: BorderStyle.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: L.v(40),
      child: TextFormField(
        controller: widget.controller,
        maxLines: 1,
        scrollPadding: EdgeInsets.all(kBaseSize * 2),
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        style: Ts.t2Reg(_textColor),
        enableInteractiveSelection: widget.enableInteractiveSelection,
        cursorColor: Theme.of(context).primaryColor,
        onChanged: _onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 5),
          filled: true,
          fillColor: Colors.grey[200],
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
            color: Colors.grey,
            decoration: TextDecoration.none,
          ),
          border: _border,
          focusedBorder: _border,
          enabledBorder: _border,
          suffixIcon: _wSuffix(),
          prefixIcon: _wPrefix(),
        ),
      ),
    );
  }
}
