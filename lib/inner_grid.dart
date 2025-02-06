import 'package:flutter/material.dart';

class InnerGrid extends StatelessWidget {
  final List<int> values; // Values for the 3x3 sub-grid
  final double boxSize;

  const InnerGrid({Key? key, required this.boxSize, required this.values}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        return Container(
          width: boxSize / 3,
          height: boxSize / 3,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 0.3,
            ),
          ),
          child: Center(
            child: Text(
              values[index] != 0 ? values[index].toString() : '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}
