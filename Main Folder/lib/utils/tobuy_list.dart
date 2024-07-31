import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class ToBuyList extends StatefulWidget {
  const ToBuyList({
    super.key,
    required this.itemName,
    required this.itemCompleted,
    required this.onChanged,
    this.deleteFunction,
  });

  final String itemName;
  final bool itemCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;

  @override
  _ToBuyListState createState() => _ToBuyListState();
}

class _ToBuyListState extends State<ToBuyList>
    with SingleTickerProviderStateMixin {
  late bool isChecked;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    isChecked = widget.itemCompleted;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleCheckbox(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
    if (isChecked) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (widget.onChanged != null) {
      widget.onChanged!(isChecked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Slidable(
        // Ensure that the Slidable widget wraps the entire container
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                if (widget.deleteFunction != null) {
                  widget.deleteFunction!(context);
                }
              },
              icon: Icons.delete,
              backgroundColor: Color(0xFFe4595c),
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 10,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFfbf7f4),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFebe1d7),
                width: 2.0,
              ),
            ),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => toggleCheckbox(!isChecked),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecked
                        ? const Color(0xFF816c61)
                        : Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFF816c61),
                      width: 2.0,
                    ),
                  ),
                  child: ClipOval(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isChecked ? 1.0 : 0.0,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.itemName,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF59534e),
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
