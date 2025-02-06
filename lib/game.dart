import 'package:flutter/material.dart';
import 'package:sudoku_api/sudoku_api.dart';
import 'inner_grid.dart';

class Game extends StatefulWidget {
  const Game({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late Future<List<List<int>>> _sudokuGrid;
  int? selectedBlock;
  int? selectedCell;

  @override
  void initState() {
    super.initState();
    _sudokuGrid = generateSudoku();
  }

  /// Génère une grille Sudoku correctement formée
  Future<List<List<int>>> generateSudoku() async {
    PuzzleOptions puzzleOptions = PuzzleOptions(patternName: "winter");
    Puzzle puzzle = Puzzle(puzzleOptions);

    await puzzle.generate();

    List<List<int>> grid = List.generate(9, (i) => List.generate(9, (j) => 0));

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        grid[i][j] = puzzle.board()?.matrix()?[i][j].getValue() ?? 0;
      }
    }

    return grid;
  }

  /// Met à jour l'état lorsqu'une cellule est sélectionnée
  void onCellTap(int blockIndex, int cellIndex) {
    setState(() {
      selectedBlock = blockIndex;
      selectedCell = cellIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 2;
    var width = MediaQuery.of(context).size.width;
    var maxSize = height > width ? width : height;
    var boxSize = (maxSize / 3).ceil().toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<List<int>>>(
          future: _sudokuGrid,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text("Erreur lors de la génération du Sudoku");
            }

            final grid = snapshot.data!;

            return SizedBox(
              height: boxSize * 3,
              width: boxSize * 3,
              child: GridView.count(
                crossAxisCount: 3,
                children: List.generate(9, (blockIndex) {
                  List<int> values = [];
                  int startRow = (blockIndex ~/ 3) * 3;
                  int startCol = (blockIndex % 3) * 3;

                  for (int i = 0; i < 3; i++) {
                    for (int j = 0; j < 3; j++) {
                      values.add(grid[startRow + i][startCol + j]);
                    }
                  }

                  return Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 1),
                    ),
                    child: InnerGrid(
                      boxSize: boxSize,
                      values: values,
                      blockIndex: blockIndex,
                      selectedBlock: selectedBlock,
                      selectedCell: selectedCell,
                      onCellTap: onCellTap, // Passe la fonction de sélection
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
