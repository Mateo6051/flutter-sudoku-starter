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
  late Puzzle puzzle;
  late Future<List<List<int>>> _sudokuGrid;
  int? selectedBlock;
  int? selectedCell;

  @override
  void initState() {
    super.initState();
    _sudokuGrid = generateSudoku();
  }

  /// Génère une grille Sudoku
  Future<List<List<int>>> generateSudoku() async {
    PuzzleOptions puzzleOptions = PuzzleOptions(patternName: "winter");
    puzzle = Puzzle(puzzleOptions);
    await puzzle.generate();

    return extractGrid();
  }

  /// Extrait la grille depuis le Puzzle
  List<List<int>> extractGrid() {
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

  /// Insère une valeur dans la cellule sélectionnée
  void insertValue(int value) {
    if (selectedBlock == null || selectedCell == null) return;

    int row = (selectedBlock! ~/ 3) * 3 + (selectedCell! ~/ 3);
    int col = (selectedBlock! % 3) * 3 + (selectedCell! % 3);

    setState(() {
      Position position = Position(row: row, column: col);
      puzzle.board()!.cellAt(position).setValue(value);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<List<List<int>>>(
            future: _sudokuGrid,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text("Erreur lors de la génération du Sudoku");
              }

              final grid = extractGrid();

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
                        onCellTap: onCellTap,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          buildNumberPad(),
        ],
      ),
    );
  }

  /// Construit le pavé numérique
  Widget buildNumberPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return buildNumberButton(index + 1);
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return buildNumberButton(index + 6);
          }),
        ),
      ],
    );
  }

  /// Construit un bouton pour un chiffre donné
  Widget buildNumberButton(int number) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () => insertValue(number),
        child: Text(number.toString(), style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
