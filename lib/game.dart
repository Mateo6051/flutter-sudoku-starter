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
  late List<List<int>> _solutionGrid;
  List<List<int>> currentGrid = List.generate(9, (i) => List.filled(9, 0)); // Grid in memory
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

    _solutionGrid = extractSolution();
    currentGrid = extractGrid(); // Store initial grid state

    return currentGrid;
  }

  /// Extrait la grille actuelle (avec valeurs affichées)
  List<List<int>> extractGrid() {
    return List.generate(9, (i) => List.generate(9, (j) {
      return puzzle.board()?.matrix()?[i][j].getValue() ?? 0;
    }));
  }

  /// Extrait la solution complète du Sudoku
  List<List<int>> extractSolution() {
    return List.generate(9, (i) => List.generate(9, (j) {
      return puzzle.solvedBoard()?.matrix()?[i][j].getValue() ?? 0;
    }));
  }

  /// Handles cell selection
  void onCellTap(int blockIndex, int cellIndex) {
    setState(() {
      selectedBlock = blockIndex;
      selectedCell = cellIndex;
    });
  }

  /// Inserts a number into the selected cell (without reloading the whole grid)
  void insertValue(int value) {
    if (selectedBlock == null || selectedCell == null) return;

    int row = (selectedBlock! ~/ 3) * 3 + (selectedCell! ~/ 3);
    int col = (selectedBlock! % 3) * 3 + (selectedCell! % 3);

    setState(() {
      Position position = Position(row: row, column: col);
      puzzle.board()!.cellAt(position).setValue(value);

      // Update only the selected cell
      currentGrid[row][col] = value;
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
        children: [
          /// Sudoku Grid
          Expanded(
            flex: 6,
            child: Center(
              child: FutureBuilder<List<List<int>>>(
                future: _sudokuGrid,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Erreur lors de la génération du Sudoku");
                  }

                  return SizedBox(
                    height: boxSize * 3,
                    width: boxSize * 3,
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: List.generate(9, (blockIndex) {
                        List<int> values = [];
                        List<int> expectedValues = [];
                        int startRow = (blockIndex ~/ 3) * 3;
                        int startCol = (blockIndex % 3) * 3;

                        for (int i = 0; i < 3; i++) {
                          for (int j = 0; j < 3; j++) {
                            values.add(currentGrid[startRow + i][startCol + j]); // Use currentGrid
                            expectedValues.add(_solutionGrid[startRow + i][startCol + j]);
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
                            expectedValues: expectedValues,
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
            ),
          ),

          const SizedBox(height: 20),

          /// Number Pad (Fixed Position)
          Expanded(
            flex: 2,
            child: buildNumberPad(),
          ),
        ],
      ),
    );
  }

  /// Builds the number selection pad
  Widget buildNumberPad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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

  /// Builds a button for selecting a number
  Widget buildNumberButton(int number) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () => insertValue(number),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: Text(number.toString()),
      ),
    );
  }
}
