import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/constants/constants.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/core/widgets/empty.dart';

class InputSearch extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final String hintText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool enableInteractiveSelection;
  final Color? textColor;

  const InputSearch({
    Key? key,
    required this.onChanged,
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
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _textColor {
    return widget.textColor != null ? widget.textColor! : Config.primaryColor;
  }

  void _onChanged(String value) {
    TextSelection prevSelection = _controller.selection;
    _controller.selection = prevSelection;

    widget.onChanged(value);
    setState(() {});
  }

  /// Without IconButton wrapper it rendered not correctly
  Widget _wPrefix() {
    return IconButton(
      onPressed: null,
      icon: SvgPicture.asset(
        "assets/icons/search.svg",
        width: kBaseSize,
        height: kBaseSize,
        color: Config.primaryColor,
      ),
    );
  }

  Widget _wSuffix() {
    if (_controller.text.isNotEmpty) {
      return IconButton(
        constraints: const BoxConstraints(),
        onPressed: () {
          _controller.clear();
          _onChanged('');
        },
        iconSize: kBaseSize,
        color: Config.grayG2Color,
        icon: const Icon(Icons.cancel),
      );
    }

    return Empty();
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
        controller: _controller,
        maxLines: 1,
        scrollPadding: EdgeInsets.all(kBaseSize * 2),
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        style: Ts.text15(_textColor),
        enableInteractiveSelection: widget.enableInteractiveSelection,
        cursorColor: Config.primaryColor,
        onChanged: _onChanged,
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
