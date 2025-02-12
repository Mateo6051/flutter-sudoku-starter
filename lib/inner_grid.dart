import 'package:flutter/material.dart';

class InnerGrid extends StatelessWidget {
  final List<int> values; // Valeurs actuelles
  final List<int> expectedValues; // Valeurs attendues (solution)
  final double boxSize;
  final int blockIndex;
  final Function(int, int) onCellTap;
  final int? selectedBlock;
  final int? selectedCell;

  const InnerGrid({
    Key? key,
    required this.boxSize,
    required this.values,
    required this.expectedValues,
    required this.blockIndex,
    required this.onCellTap,
    this.selectedBlock,
    this.selectedCell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (cellIndex) {
        bool isSelected = (blockIndex == selectedBlock && cellIndex == selectedCell);
        bool isEmpty = values[cellIndex] == 0; // Case vide ?
        int expectedValue = expectedValues[cellIndex]; // Valeur attendue

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
                isEmpty ? expectedValue.toString() : values[cellIndex].toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEmpty ? Colors.black12 : Colors.black,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
