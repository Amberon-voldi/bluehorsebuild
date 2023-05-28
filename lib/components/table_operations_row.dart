import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableOperationsRow extends StatefulWidget {
  const TableOperationsRow({super.key});

  @override
  State<TableOperationsRow> createState() => _TableOperationsRowState();
}

class _TableOperationsRowState extends State<TableOperationsRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OperationButton(
          title: "COPY",
          onPressed: () {},
        ),
        OperationButton(
          title: "EXCEL",
          onPressed: () {},
        ),
        OperationButton(
          title: "PDF",
          onPressed: () {},
        ),
        OperationButton(
          title: "PRINT",
          onPressed: () {},
        ),
      ],
    );
  }
}

class OperationButton extends StatelessWidget {
  const OperationButton({
    super.key,
    required this.title,
    this.onPressed,
  });

  final String title;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        shape: const ContinuousRectangleBorder(),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Text(
          title,
          style: GoogleFonts.urbanist(
            color: Colors.black87,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
