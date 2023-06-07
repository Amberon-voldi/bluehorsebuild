import 'package:bluehorsebuild/components/search_bar.dart' as bar;
import 'package:bluehorsebuild/components/table_operations_row.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTable extends StatefulWidget {
  const CustomTable({
    super.key,
    required this.tableData,
    this.isShowEntriesVisible = false,
    this.isTableOperationsVisible = true,
    this.isTopScrollbarVisible = false,
  });

  final List<List> tableData;
  final bool isShowEntriesVisible;
  final bool isTableOperationsVisible;
  final bool isTopScrollbarVisible;

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  int numberOfRowsShown = 10;
  late int start;
  late int end;
  late List<List> shownData;
  late int tableLength;
  late int tablePages;
  late int lastPageStart;

  TextEditingController searchController = TextEditingController();
  ScrollController tableScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    tableLength = widget.tableData.length - 1;
    tablePages = ((tableLength) / numberOfRowsShown).ceil();
    lastPageStart = (tablePages == 0) ? 1 : (((tablePages - 1) * 10) + 1);
    updateData(1);
    searchController.addListener(() {
      updateData(1);
    });
  }

  void updateData(newStart) {
    start = newStart;
    end = start + numberOfRowsShown;
    var searchKeyword = searchController.text.trim();
    if (searchKeyword.isNotEmpty) {
      var searchedResult = widget.tableData
          .sublist(1)
          .where((row) => row.any((element) => element
              .toString()
              .toLowerCase()
              .contains(searchKeyword.toLowerCase())))
          .toList();
      shownData = [
        widget.tableData[0],
        ...(searchedResult.isEmpty)
            ? []
            : searchedResult.sublist(
                start,
                (end < (searchedResult.length - 1))
                    ? end
                    : (searchedResult.length - 1) + 1),
      ];
    } else {
      shownData = [
        widget.tableData[0],
        ...widget.tableData.sublist(
          start,
          (end < tableLength) ? end : tableLength + 1,
        )
      ];
    }
    if (context.mounted) {
      setState(() {});
    }
  }

  List<Widget> generatePageNumbers() {
    List<Widget> pageNumbers = [];

    if (tablePages <= 6) {
      pageNumbers = List.generate(tablePages, (index) => index + 1)
          .map(
            (number) => buildPageNumberBox(number),
          )
          .toList();
    } else {
      if (start <= 41) {
        pageNumbers = [
          for (var i = 1; i <= 5; i++) buildPageNumberBox(i),
          buildEllipsis(),
          buildPageNumberBox(tablePages),
        ];
      } else if (start >= lastPageStart - 40) {
        pageNumbers = [
          buildPageNumberBox(1),
          buildEllipsis(),
          for (var i = ((lastPageStart - 40) / 10).ceil(); i <= tablePages; i++)
            buildPageNumberBox(i),
        ];
      } else {
        pageNumbers = [
          buildPageNumberBox(1),
          buildEllipsis(),
          for (var i = ((start + 1) / 10).ceil();
              i <= (start / 10).ceil() + 3;
              i++)
            buildPageNumberBox(i),
          buildEllipsis(),
          buildPageNumberBox(tablePages),
        ];
      }
    }

    return pageNumbers;
  }

  Widget buildPageNumberBox(int number) {
    return InkWell(
      onTap: () => updateData(((number - 1) * 10) + 1),
      child: NumberBox(
        number: number,
        isSelected: start == ((number - 1) * 10) + 1,
      ),
    );
  }

  Widget buildEllipsis() {
    return Text(
      '...',
      style: GoogleFonts.urbanist(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.isTableOperationsVisible
            ? const TableOperationsRow()
            : Container(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isShowEntriesVisible
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Show",
                        style: GoogleFonts.urbanist(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                      DropdownButton2(
                        buttonStyleData: const ButtonStyleData(
                          decoration: BoxDecoration(
                            border: Border.fromBorderSide(BorderSide.none),
                          ),
                        ),
                        iconStyleData: const IconStyleData(iconSize: 0),
                        menuItemStyleData: const MenuItemStyleData(height: 35),
                        dropdownStyleData:
                            const DropdownStyleData(padding: EdgeInsets.zero),
                        items: [10, 25, 50, 100]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Center(
                                  child: Text(
                                    "$value",
                                    style: GoogleFonts.urbanist(),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        value: numberOfRowsShown,
                        onChanged: (value) {
                          numberOfRowsShown = value as int;
                          updateData(1);
                          setState(() {});
                        },
                      ),
                      Text(
                        "entries",
                        style: GoogleFonts.urbanist(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                : Container(),
            const Spacer(),
            bar.SearchBar(controller: searchController),
          ],
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 350,
          ),
          child: widget.isTopScrollbarVisible
              ? Scrollbar(
                  controller: tableScrollController,
                  thumbVisibility: true,
                  scrollbarOrientation: ScrollbarOrientation.top,
                  child: Scrollbar(
                    controller: tableScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: tableScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            children: shownData
                                .map(
                                  (row) => TableRow(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom:
                                            BorderSide(color: Colors.black26),
                                      ),
                                    ),
                                    children: row
                                        .map(
                                          (entry) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 15.0,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: (![
                                                int,
                                                String,
                                                double,
                                                Map,
                                                List,
                                                Set
                                              ].contains(entry.runtimeType))
                                                  ? entry
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10.0),
                                                      child: Text(
                                                        entry.toString(),
                                                        style: GoogleFonts
                                                            .urbanist(
                                                          fontWeight: widget
                                                                      .tableData
                                                                      .indexOf(
                                                                          row) ==
                                                                  0
                                                              ? FontWeight.bold
                                                              : FontWeight.w400,
                                                          color: widget
                                                                      .tableData
                                                                      .indexOf(
                                                                          row) ==
                                                                  0
                                                              ? Colors.black
                                                              : Colors.black87,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                )
                                .toList(),
                          ),
                          (shownData.length == 1)
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                    "No Data available in table",
                                    style: GoogleFonts.urbanist(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                )
              : Scrollbar(
                  controller: tableScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: tableScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Table(
                          defaultColumnWidth: const IntrinsicColumnWidth(),
                          children: shownData
                              .map(
                                (row) => TableRow(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black26),
                                    ),
                                  ),
                                  children: row
                                      .map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 15.0,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: (![
                                              int,
                                              String,
                                              double,
                                              Map,
                                              List,
                                              Set
                                            ].contains(entry.runtimeType))
                                                ? entry
                                                : Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 10.0),
                                                    child: Text(
                                                      entry.toString(),
                                                      style:
                                                          GoogleFonts.urbanist(
                                                        fontWeight: widget
                                                                    .tableData
                                                                    .indexOf(
                                                                        row) ==
                                                                0
                                                            ? FontWeight.bold
                                                            : FontWeight.w400,
                                                        color: widget.tableData
                                                                    .indexOf(
                                                                        row) ==
                                                                0
                                                            ? Colors.black
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                        (shownData.length == 1)
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                  "No Data available in table",
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(
          height: 15,
        ),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Text(
                "Showing ${tableLength > 0 ? start : 0} to ${(end < tableLength) ? end - 1 : (tableLength)} of $tableLength entries"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: (start != 1)
                      ? () => updateData(start - numberOfRowsShown)
                      : null,
                  child: Text(
                    "Prev",
                    style: GoogleFonts.urbanist(
                      color: (start != 1) ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                ...generatePageNumbers(),
                TextButton(
                  onPressed: (start != lastPageStart)
                      ? () => updateData(start + numberOfRowsShown)
                      : null,
                  child: Text(
                    "Next",
                    style: GoogleFonts.urbanist(
                      color:
                          (start != lastPageStart) ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}

class NumberBox extends StatelessWidget {
  const NumberBox({
    super.key,
    required this.number,
    required this.isSelected,
  });

  final int number;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      color: isSelected ? Colors.blue : Colors.transparent,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 2.5, right: 1.25),
      child: Text(
        number.toString(),
        style: GoogleFonts.urbanist(
          color: isSelected ? Colors.white : Colors.blue,
          fontSize: 16,
        ),
      ),
    );
  }
}
