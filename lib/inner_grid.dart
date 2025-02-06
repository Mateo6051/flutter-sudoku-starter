import 'package:flutter/material.dart';

class InnerGrid extends StatelessWidget {
  final double boxSize;

  const InnerGrid({Key? key, required this.boxSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true, // Évite le dépassement
      physics: const NeverScrollableScrollPhysics(), // Désactive le scroll
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
        );
      }),
    );
  }
}
