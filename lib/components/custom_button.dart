import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.onPressed,
    this.textStyle,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String text;
  final Color? color;
  final Color? textColor;
  final void Function()? onPressed;
  final TextStyle? textStyle;
  final Icon? leadingIcon;
  final Icon? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.red,
      ),
      onPressed: onPressed ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal:
                ((leadingIcon != null) || (trailingIcon != null)) ? 0 : 15.0,
            vertical: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            (leadingIcon != null)
                ? Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: leadingIcon!,
                  )
                : Container(),
            Text(
              text,
              style: textStyle ??
                  GoogleFonts.urbanist(
                    color: textColor ?? Colors.white,
                  ),
            ),
            (trailingIcon != null)
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: trailingIcon!,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
