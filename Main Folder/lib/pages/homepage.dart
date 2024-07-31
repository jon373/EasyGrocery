import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_grocery_nv/utils/tobuy_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  // Lalagyan ng items
  List toBuyList = [];

  void checkBoxChanged(int index) {
    setState(() {
      toBuyList[index][1] = !toBuyList[index][1];
    });
  }

  void saveNewItem() {
    // Check if the input is not empty before adding to the list
    if (_controller.text.isNotEmpty) {
      setState(() {
        toBuyList.add([_controller.text, false]);
        _controller.clear();
      });
    }
    // * * pag walang laman yung add item input hindi niya ilalagay
  }

  void deleteItem(int index) {
    setState(() {
      toBuyList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFfbf7f4),
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFfbf7f4),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFa9a59f),
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EasyGrocery',
                  style: GoogleFonts.dmSerifText(
                    color: const Color(0xFF59534e),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 50), // Adjust the padding as needed
                  child: Row(
                    children: [
                      Text(
                        'Budget:',
                        style: GoogleFonts.dmSerifText(
                          color: const Color(0xFF59534e),
                          fontSize: 18,
                        ),
                      ),
                      // Remove or reduce the SizedBox width
                      const SizedBox(
                          width:
                              0.0001), // Reduced space between the text and the input box
                      // * * TO DO: Ayusin yung input box ng amount
                      Container(
                        width: 100, // Set your desired width here
                        height: 40, // Set a fixed height for the input field
                        child: TextField(
                          keyboardType:
                              TextInputType.number, // Only number input
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter
                                .digitsOnly, // Allow only digits
                          ],
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            suffixIcon: Icon(Icons.filter_list),
                            filled: true,
                            fillColor: Color(0xFFfbf7f4),
                            border: InputBorder.none, // Remove the border
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5), // Adjust vertical padding
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the row content
              children: [
                Container(
                  width: 350, // Set your desired width here
                  height: 50, // Optional: Set your desired height
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add new item',
                      filled: true,
                      fillColor: const Color(0xFFfbf7f4),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFb3a18f),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFb3a18f),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFb3a18f),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: toBuyList.length,
              itemBuilder: (BuildContext context, index) {
                return ToBuyList(
                  itemName: toBuyList[index][0],
                  itemCompleted: toBuyList[index][1],
                  onChanged: (value) => checkBoxChanged(index),
                  deleteFunction: (context) => deleteItem(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
