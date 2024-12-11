// IM/2021/096 - W.P.C. Nimesha
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; //importing maths package
import './widgets/calculator_button.dart'; //imporing caluculator button widget

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Calculator',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Calculator'), //for displaying title
        ),
        body: const Calculator(),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _input = ''; 
  String _calculationInput = ''; 
  String _output = ''; 
  bool _isResultDisplayed = false;  
  List<String> _history = []; //to store calculations history

//Method: handle button pressing
  void _onButtonPressed(String label) {
  setState(() {
    const operators = ['+', '-', 'x', '/', '^'];

    if (_isResultDisplayed) { //checking whether result is displayed, if the result is dispayed then clear the display
      _input = '';
      _calculationInput = '';
      _output = '';
      _isResultDisplayed = false;
    }

    if (label == 'AC') {
      _clear(); //all clear the display
    } else if (label == '⌫') {
      _delete(); //delete only the last character of current string
    } else if (label == '=') {
      _evaluateFinal();
    } else if (operators.contains(label)) { //handling operators
      if ((label == '-' || label == '√') && _input.isEmpty) {
           _appendOperator(label, label == '√' ? 'sqrt(' : label); //allowing "-" and "√" even if the calculation box is empty
      } else if (_input.isNotEmpty && !operators.contains(_input[_input.length - 1])) {
           _appendOperator(label, label == 'x' ? '*' : label); //if the last character is not operator then append operator
      }
    } else if (label == '√') {
      _appendOperator('√', 'sqrt(');  
    } else if (label == '%') {
      _appendOperator('%', '/100');
    } else if (label == '!') {
      _appendFactorial();
    } else if (label == '()') {
      _appendParentheses();
    } else {
      _appendValue(label, label); //handling numbers and other values
    }
  });
}


  void _clear() { //all clear the display
    _input = '';
    _calculationInput = '';
    _output = '';
    _isResultDisplayed = false;
  }

  void _delete() { //delete only the last character of current string 
    if (_input.isNotEmpty) {
      _input = _input.substring(0, _input.length - 1);
      _calculationInput = _calculationInput.isNotEmpty
          ? _calculationInput.substring(0, _calculationInput.length - 1)
          : '';
      _evaluateIntermediate();
    }
  }
  //method: append operators to the input (from the display and calculation strings
  void _appendOperator(String display, String calculation) {
  if (display == '√') { //allowing "√" as the first input or after an operator
    if (_input.isEmpty || _isLastCharOperator()) {
      _input += display;
      _calculationInput += calculation;
    } else if (!_isLastCharOperator() && !_input.endsWith('(')) { //ensures multiplication is implied when needed 
      _input += 'x' + display; 
      _calculationInput += '*' + calculation;
    }
  } else if (display == '-' && _input.isEmpty) { //allowing enter "-" when input is empty
      _input += display;
    _calculationInput += calculation;
  } else if (_input.isEmpty || _isLastCharOperator()) {
    return; //preventing other operators when input is empty
  } else {
    _input += display;
    _calculationInput += calculation;
  }
}

  void _appendParentheses() { //method: handle parantheses inputs
    if (_input.isEmpty) {
      _input += '(';
      _calculationInput += '('; //when the input is empty, then add open paranthesis
    } else {
      int openParentheses = _input.split('(').length - 1;
      int closeParentheses = _input.split(')').length - 1;

      if (openParentheses > closeParentheses && !_isLastCharOperator() && !_input.endsWith('(')) {
        _input += ')';
        _calculationInput += ')';
      } else {
        if (_input.isNotEmpty && !_isLastCharOperator() && !_input.endsWith('(')) {
          _input += '(';
          _calculationInput += '*(';
        } else {
          _input += '(';
          _calculationInput += '(';
        }
      }
    }
  }

  //method: append a number or decimal to the input
  void _appendValue(String display, String calculation) {
  if (_input.endsWith('√')) {
    //automatically add parentheses after "√"
    _input += '(' + display;
    _calculationInput += '(' + calculation;
  } else {
    if (display == '.' && _input.endsWith('.')) return; 
    _input += display;
    _calculationInput += calculation;
  }
  _evaluateIntermediate(); //update intermediate result
}

  //method: calculate factorial
  void _appendFactorial() {
    if (_input.isEmpty || _isLastCharOperator()) return;

    int number;
    try {
      number = int.parse(_input.split(RegExp(r'[+\-x/^()]')).last);
    } catch (_) {
      _output = 'Format Error';
      return;
    }

    int factorialResult = 1;
    for (int i = 1; i <= number; i++) {
      factorialResult *= i;
    }

    _input += '!';
    _calculationInput = _calculationInput.replaceFirst(
        RegExp(r'[+\-x/^]*\d+$'), factorialResult.toString());
    _evaluateIntermediate();
  }

  //method: to check whether if the last character is an operator
  bool _isLastCharOperator() {
    if (_input.isEmpty) return false;
    const operators = ['+', '-', 'x', '/', '^'];
    return operators.contains(_input[_input.length - 1]);
  }

  
String _normalizeInput(String input) { //normalize the input string removing leading zeros
  return input.replaceAllMapped(
    RegExp(r'(\D|^)(0+)(\d)'), 
    (match) => '${match.group(1)}${match.group(3)}',
  );
}

  void _evaluateIntermediate() {
  try {
    String tempCalculation = _normalizeInput(_calculationInput); //normalize input
    int openParentheses = tempCalculation.split('(').length - 1;
    int closeParentheses = tempCalculation.split(')').length - 1;

    while (openParentheses > closeParentheses) {
      tempCalculation += ')';
      closeParentheses++;
    }

    if (tempCalculation.isNotEmpty) {
      if (tempCalculation.contains('/0')) {
        _output = "Can't divide by 0";
        return;
      }

      if (tempCalculation.contains('sqrt')) { //handles negative numbers' squareroot
        RegExp sqrtRegex = RegExp(r'sqrt\((-?\d+(\.\d+)?)\)');
        Iterable<Match> matches = sqrtRegex.allMatches(tempCalculation);

        for (Match match in matches) {
          double? value = double.tryParse(match.group(1)!);
          if (value != null && value < 0) {
            _output = "Keep it real";
            return;
          }
        }
      }

      Parser parser = Parser();
      Expression expression = parser.parse(tempCalculation);
      ContextModel contextModel = ContextModel();
      double result = expression.evaluate(EvaluationType.REAL, contextModel);

      _output = result % 1 == 0    ? result.toInt().toString()  : result.toStringAsFixed(10); //define decimal points
    }
  } catch (_) {
    _output = 'Format Error';
  }
}


void _evaluateFinal() { //evaluating final value
  if (_calculationInput.isEmpty) {
    setState(() {
      _output = _input;
    });
    return;
  }

  try {
    String normalizedCalculation = _normalizeInput(_calculationInput); //Normalize input 
    if (normalizedCalculation.contains('/0')) {
      setState(() {
        _input = '';
        _calculationInput = '';
        _output = "Can't divide by 0";
      });
      return;
    }

    if (normalizedCalculation.contains('sqrt')) {
      RegExp sqrtRegex = RegExp(r'sqrt\((-?\d+(\.\d+)?)\)');
      Iterable<Match> matches = sqrtRegex.allMatches(normalizedCalculation);

      for (Match match in matches) {
        double? value = double.tryParse(match.group(1)!);
        if (value != null && value < 0) {
          setState(() {
            _output = "Keep it real";
          });
          return;
        }
      }
    }

    Parser parser = Parser();
    Expression expression = parser.parse(normalizedCalculation);
    ContextModel contextModel = ContextModel();
    double result = expression.evaluate(EvaluationType.REAL, contextModel);

    setState(() {
      _output = result % 1 == 0    ? result.toInt().toString()  : result.toStringAsFixed(10); //define decimal points
      _calculationInput = _input;
      _output = '';
      _isResultDisplayed = true;
      _history.add("$_calculationInput = $result");
    });
  } catch (_) {
    setState(() {
      _output = 'Invalid Input';
    });
  }
}


  void _showHistory() { //method: showing history
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calculation History'),
          content: SingleChildScrollView(
            child: Column(
              children: _history.reversed.map((item) => ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    _input = item.split('=')[0].trim();
                    _calculationInput = _input;
                    _evaluateIntermediate();
                  });
                  Navigator.of(context).pop();
                },
              )).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) { //building calculator grid UI
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 100,
              child: Container(
                padding: const EdgeInsets.only(right: 12),
                alignment: Alignment.centerRight,
                child: Text(
                  _input,
                  style: const TextStyle(fontSize: 30, color: Colors.grey),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerRight,
              child: Text(
                _output,
                style: TextStyle(
                  fontSize: _output.contains("Error") || _output.contains("Can't")
                      ? 18
                      : 48,
                  color: _output.contains("Error") || _output.contains("Can't")
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 10),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton(
                  label: '√',
                  onPressed: () => _onButtonPressed('√'),
                  width: 70,
                  height: 50,
                  backgroundColor: const Color.fromARGB(255, 220, 230, 240),
                ),
                CalculatorButton(
                  label: 'π',
                  onPressed: () => _onButtonPressed('π'),
                  width: 70,
                  height: 50,
                  backgroundColor: const Color.fromARGB(255, 220, 230, 240),
                ),
                CalculatorButton(
                  label: '^',
                  onPressed: () => _onButtonPressed('^'),
                  width: 70,
                  height: 50,
                  backgroundColor: const Color.fromARGB(255, 220, 230, 240),
                ),
                CalculatorButton(
                  label: '!',
                  onPressed: () => _onButtonPressed('!'),
                  width: 70,
                  height: 50,
                  backgroundColor: const Color.fromARGB(255, 220, 230, 240),
                ),
              ],
            ),
          

        
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton(label: 'AC', onPressed: () => _onButtonPressed('AC'), backgroundColor:Color.fromARGB(255, 154, 252, 193),),
                CalculatorButton(label: '()', onPressed: () => _onButtonPressed('()'), backgroundColor:Color.fromARGB(255, 154, 190, 252),),
                CalculatorButton(label: '%', onPressed: () => _onButtonPressed('%'), backgroundColor:Color.fromARGB(255, 154, 190, 252),),
                CalculatorButton(label: '/', onPressed: () => _onButtonPressed('/'), backgroundColor:Color.fromARGB(255, 154, 190, 252),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton(label: '7', onPressed: () => _onButtonPressed('7')),
                CalculatorButton(label: '8', onPressed: () => _onButtonPressed('8')),
                CalculatorButton(label: '9', onPressed: () => _onButtonPressed('9')),
                CalculatorButton(label: 'x', onPressed: () => _onButtonPressed('x'), backgroundColor:Color.fromARGB(255, 154, 190, 252),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton(label: '4', onPressed: () => _onButtonPressed('4')),
                CalculatorButton(label: '5', onPressed: () => _onButtonPressed('5')),
                CalculatorButton(label: '6', onPressed: () => _onButtonPressed('6')),
                CalculatorButton(label: '-', onPressed: () => _onButtonPressed('-'), backgroundColor:Color.fromARGB(255, 154, 190, 252),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton(label: '1', onPressed: () => _onButtonPressed('1')),
                CalculatorButton(label: '2', onPressed: () => _onButtonPressed('2')),
                CalculatorButton(label: '3', onPressed: () => _onButtonPressed('3')),
                CalculatorButton(label: '+', onPressed: () => _onButtonPressed('+'), backgroundColor:Color.fromARGB(255, 154, 190, 252),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton(label: '0', onPressed: () => _onButtonPressed('0')),
                CalculatorButton(label: '.', onPressed: () => _onButtonPressed('.')),
                CalculatorButton(label: '⌫', onPressed: () => _onButtonPressed('⌫')),
                CalculatorButton(label: '=', onPressed: () => _onButtonPressed('='), backgroundColor:Color.fromARGB(255, 165, 154, 252),),
              ],
            ),
          ],
        ),
      ]    
    ),

        Positioned(
          right: 10,
          top: 0,
          child: IconButton(
            onPressed: _showHistory,  //Show history
            icon: const Icon(
              Icons.history, //to use history 
              color: Colors.blueGrey,
              size: 30, 
            ),
          
          ),
        ),
      ],
    );
  }
}
