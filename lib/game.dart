import 'package:flutter/material.dart';
import 'package:sudoku_api/sudoku_api.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
  List<List<int>> currentGrid = List.generate(9, (i) => List.filled(9, 0));
  int? selectedBlock;
  int? selectedCell;
  bool _showSolution = false; // Variable pour afficher ou cacher la solution

  @override
  void initState() {
    super.initState();
    _sudokuGrid = generateSudoku();
  }

  Future<List<List<int>>> generateSudoku() async {
    PuzzleOptions puzzleOptions = PuzzleOptions(patternName: "winter");
    puzzle = Puzzle(puzzleOptions);
    await puzzle.generate();

    _solutionGrid = extractSolution();
    currentGrid = extractGrid();

    return currentGrid;
  }

  List<List<int>> extractGrid() {
    return List.generate(9, (i) => List.generate(9, (j) {
      return puzzle.board()?.matrix()?[i][j].getValue() ?? 0;
    }));
  }

  List<List<int>> extractSolution() {
    return List.generate(9, (i) => List.generate(9, (j) {
      return puzzle.solvedBoard()?.matrix()?[i][j].getValue() ?? 0;
    }));
  }

  void onCellTap(int blockIndex, int cellIndex) {
    setState(() {
      selectedBlock = blockIndex;
      selectedCell = cellIndex;
    });
  }

  void insertValue(int value) {
    if (selectedBlock == null || selectedCell == null) return;

    int row = (selectedBlock! ~/ 3) * 3 + (selectedCell! ~/ 3);
    int col = (selectedBlock! % 3) * 3 + (selectedCell! % 3);
    int correctValue = _solutionGrid[row][col];

    if (value == correctValue) {
      setState(() {
        Position position = Position(row: row, column: col);
        puzzle.board()!.cellAt(position).setValue(value);
        currentGrid[row][col] = value;
      });
    } else {
      showErrorSnackbar();
    }
  }

  void showErrorSnackbar() {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Wrong value',
        message: 'Please try another one',
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Toggle pour afficher/masquer la solution
  void toggleSolution() {
    setState(() {
      _showSolution = !_showSolution;
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
          Center(
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
                          values.add(currentGrid[startRow + i][startCol + j]);
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
                          showSolution: _showSolution, // Passe l'état au widget
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          /// Number Pad (closer to the grid)
          buildNumberPad(),

          /// Button to Show/Hide Solution
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              onPressed: toggleSolution,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _showSolution ? "Hide Solution" : "Show Solution",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return buildNumberButton(index + 1);
            }),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return buildNumberButton(index + 6);
            }),
          ),
        ],
      ),
    );
  }

  Widget buildNumberButton(int number) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ElevatedButton(
        onPressed: () => insertValue(number),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(number.toString(), style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
