import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config.dart';
import '../constants/constants.dart';
import '../services/l.dart';
import '../services/ts.dart';
import 'empty.dart';

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
  _InputSearchState createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  Color get _textColor {
    return widget.textColor != null ? widget.textColor! : Config.primaryColor;
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
        'assets/icon/search.svg',
        package: 'ttp_chat',
        width: kBaseSize,
        height: kBaseSize,
        color: Config.primaryColor,
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

    return const Empty();
  }

  OutlineInputBorder get _enabledBorder {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Config.grayG4Color, width: L.v(1)),
    );
  }

  OutlineInputBorder get _focusedBorder {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Config.grayG5Color, width: L.v(1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: L.v(35),
      child: TextFormField(
        controller: widget.controller,
        maxLines: 1,
        scrollPadding: EdgeInsets.all(kBaseSize * 2),
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        style: Ts.text15(_textColor),
        enableInteractiveSelection: widget.enableInteractiveSelection,
        cursorColor: Config.primaryColor,
        onChanged: _onChanged,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          filled: true,
          fillColor: Config.grayG5Color,
          contentPadding: EdgeInsets.zero,
          hintText: widget.hintText,
          hintStyle: Ts.text15(Config.grayG2Color),
          enabledBorder: _enabledBorder,
          focusedBorder: _focusedBorder,
          suffixIcon: _wSuffix(),
          prefixIcon: _wPrefix(),
        ),
      ),
    );
  }
}
