import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClickableText extends StatefulWidget {
  const ClickableText({super.key, required this.text, this.onPressed});

  final String text;
  final void Function()? onPressed;

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: widget.onPressed,
        child: Text(
          widget.text,
          style: GoogleFonts.urbanist(
            color: widget.onPressed != null ? Colors.purple : null,
          ),
        ),
      ),
    );
  }
}
