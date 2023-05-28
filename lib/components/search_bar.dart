import 'package:bluehorsebuild/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Search: ",
          style: GoogleFonts.urbanist(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          width: 150,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              CustomTextField(controller: controller),
              controller.text.isNotEmpty
                  ? InkWell(
                      onTap: () => controller.clear(),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.grey,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}
