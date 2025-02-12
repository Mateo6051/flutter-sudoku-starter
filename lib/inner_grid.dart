import 'package:flutter/material.dart';

class InnerGrid extends StatelessWidget {
  final List<int> values; // Current puzzle values
  final List<int> expectedValues; // Solution values
  final double boxSize;
  final int blockIndex;
  final Function(int, int) onCellTap;
  final int? selectedBlock;
  final int? selectedCell;
  final bool showSolution; // NEW: Toggle for showing the solution

  const InnerGrid({
    Key? key,
    required this.boxSize,
    required this.values,
    required this.expectedValues,
    required this.blockIndex,
    required this.onCellTap,
    this.selectedBlock,
    this.selectedCell,
    required this.showSolution, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (cellIndex) {
        bool isSelected = (blockIndex == selectedBlock && cellIndex == selectedCell);
        bool isEmpty = values[cellIndex] == 0; // Check if cell is empty
        int expectedValue = expectedValues[cellIndex]; // Get expected solution value

        return InkWell(
          onTap: () => onCellTap(blockIndex, cellIndex),
          child: Container(
            width: boxSize / 3,
            height: boxSize / 3,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.3),
              color: isSelected ? Colors.blueAccent.shade100.withAlpha(100) : Colors.transparent,
            ),
            child: Center(
              child: Text(
                showSolution || !isEmpty
                    ? expectedValue.toString() // Show solution if enabled
                    : values[cellIndex] != 0
                    ? values[cellIndex].toString() // Show user-entered value
                    : '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: (showSolution && isEmpty) ? Colors.black12 : Colors.black,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
