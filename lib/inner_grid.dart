import 'package:flutter/material.dart';

class InnerGrid extends StatelessWidget {
  final List<int> values;
  final double boxSize;
  final int blockIndex;
  final Function(int, int) onCellTap; // Callback pour informer Game
  final int? selectedBlock;
  final int? selectedCell;

  const InnerGrid({
    Key? key,
    required this.boxSize,
    required this.values,
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
                values[cellIndex] != 0 ? values[cellIndex].toString() : '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }),
    );
  }
}
