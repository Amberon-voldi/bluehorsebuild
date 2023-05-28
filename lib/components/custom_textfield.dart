import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.enabledBorder,
    this.focusedBorder,
    this.isDense,
    this.hintStyle,
    this.labelStyle,
    this.style,
    this.showLabel = true,
    this.enabled,
    this.maxLines,
  });

  final TextEditingController? controller;
  final int? maxLines;
  final String? hintText;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final bool? isDense;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? style;
  final bool showLabel;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: key,
      enabled: enabled,
      controller: controller,
      cursorColor: Colors.black,
      cursorWidth: 1,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: isDense ?? true,
        disabledBorder: enabledBorder ??
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
        enabledBorder: enabledBorder ??
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
        focusedBorder: focusedBorder ??
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
        hintText: !showLabel ? hintText : null,
        hintStyle: hintStyle ??
            const TextStyle(
              color: Colors.grey,
            ),
        labelText: showLabel ? hintText : null,
        labelStyle: labelStyle ??
            const TextStyle(
              color: Colors.grey,
            ),
      ),
      style: style ??
          GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class CustomDateTextField extends StatelessWidget {
  const CustomDateTextField({
    super.key,
    required this.controller,
    required this.title,
  });

  final TextEditingController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var controllerText = controller.text;
        DateTime? date;
        if (controllerText != "yyyy-mm-dd") {
          var splitList =
              controllerText.split("-").map((e) => int.parse(e)).toList();
          date = DateTime(splitList[0], splitList[1], splitList[2]);
        }
        showDatePicker(
          context: context,
          initialDate: (date != null) ? date : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        ).then((date) {
          if (date != null) {
            controller.text =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          }
        });
      },
      child: Stack(
        children: [
          CustomTextField(
            controller: controller,
            hintText: title,
            enabled: false,
          ),
          const Positioned(
            right: 10,
            bottom: 0,
            top: 10,
            child: Icon(
              Icons.calendar_month,
              color: Colors.grey,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
