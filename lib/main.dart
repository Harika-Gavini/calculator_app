import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '';
  List<String> history = []; // List to hold history of calculations
  bool showHistory = false; // Control the visibility of the history

  void appendToDisplay(String value) {
    // Prevent adding multiple decimal points to a single number
    if (value == '.') {
      // Check if the display is empty or if the last character is an operator
      if (display.isEmpty || _isLastCharacterOperator(display)) {
        return; // Prevent decimal at the start or after an operator
      }

      // Allow only one decimal point in the current number
      final lastOperatorIndex = display.lastIndexOf(RegExp(r'[+\-*/]'));
      final lastNumber = lastOperatorIndex == -1
          ? display // If there's no operator, take the whole display
          : display.substring(lastOperatorIndex + 1);

      if (lastNumber.contains('.')) {
        return; // Prevent multiple decimals in the same number
      }
    }

    setState(() {
      display += value;
    });
  }

  bool _isLastCharacterOperator(String input) {
    if (input.isEmpty) return false;
    final lastChar = input[input.length - 1];
    return ['+', '-', '*', '/'].contains(lastChar);
  }

  void calculate() {
    try {
      final String input = display;
      final RegExp regex = RegExp(r'(\d+(\.\d+)?)([+\-*/])(\d+(\.\d+)?)');
      final Match? match = regex.firstMatch(input);

      if (match != null) {
        final double num1 = double.parse(match.group(1)!);
        final String operator = match.group(3)!;
        final double num2 = double.parse(match.group(4)!);

        double result;
        switch (operator) {
          case '+':
            result = num1 + num2;
            break;
          case '-':
            result = num1 - num2;
            break;
          case '*':
            result = num1 * num2;
            break;
          case '/':
            result = num2 != 0 ? num1 / num2 : double.nan;
            break;
          default:
            return;
        }

        // Add the calculation to history
        setState(() {
          history.add('$input = $result'); // Store the calculation
          display = result.toString(); // Display the result
        });
      } else {
        setState(() {
          display = 'Error'; // Handle invalid input
        });
      }
    } catch (e) {
      setState(() {
        display = 'Error'; // Display error if calculation fails
      });
    }
  }

  void clearDisplay() {
    setState(() {
      display = ''; // Clear the display
    });
  }

  void toggleHistory() {
    setState(() {
      showHistory = !showHistory; // Toggle history visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.centerRight,
                  child: Text(
                    display,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('Clear', isClear: true, isOperator: true),
                    _buildButton('History', isHistory: true, isOperator: true),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('/', isOperator: true),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('*', isOperator: true),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('-', isOperator: true),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('.'), // Allow decimal input
                    _buildButton('0'),
                    _buildButton('=', isEqual: true, isOperator: true),
                    _buildButton('+', isOperator: true),
                  ],
                ),
                SizedBox(height: 20),
                // Display history if showHistory is true
                if (showHistory) ...[
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(history[index]),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String value,
      {bool isClear = false,
      bool isEqual = false,
      bool isOperator = false,
      bool isHistory = false}) {
    return ElevatedButton(
      onPressed: () {
        if (isClear) {
          clearDisplay();
        } else if (isHistory) {
          toggleHistory();
        } else if (isEqual) {
          calculate();
        } else {
          appendToDisplay(value);
        }
      },
      child: Text(
        value,
        style: TextStyle(fontSize: 24),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(70, 70),
        backgroundColor:
            isOperator ? Colors.orange : Colors.blue, // Orange for operators
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
