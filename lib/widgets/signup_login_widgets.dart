import 'package:flutter/material.dart';
import 'package:project_hostelite/theme/colors.dart';

Widget headingText(String text, double fontSize) {
  return Text(
    text,
    style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
  );
}

Widget subHeadingText(String text, double fontSize) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: Colors.black54,
    ),
  );
}

Widget textField(String hintText, bool obscureText, IconData icon,
    TextEditingController controller,
    {double height = 60}) {
  bool obscureText0 = obscureText;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: primaryBlue.withOpacity(0.5),
                offset: const Offset(0, 5),
                spreadRadius: -15,
                blurRadius: 20),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText0,
          style: TextStyle(color: primaryBlue),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(20),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Icon(
                icon,
                color: Colors.grey.shade400,
              ),
            ),
            suffixIcon: obscureText
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      icon: Icon(
                        obscureText0 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText0 = !obscureText0;
                        });
                      },
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide(color: primaryBlue, width: 1.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
              borderRadius: BorderRadius.circular(100),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
          ),
          cursorColor: primaryBlue,
        ),
      );
    },
  );
}

Widget textButton(String text, Color color, void Function()? onPressed) {
  return Align(
    alignment: Alignment.centerRight,
    child: GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w400, fontSize: 15),
      ),
    ),
  );
}

Widget actionButton(String text, void Function()? onPressed) {
  return Container(
    height: 60,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
            color: primaryBlue.withOpacity(0.5),
            offset: const Offset(0, 5),
            spreadRadius: -15,
            blurRadius: 20),
      ],
      borderRadius: BorderRadius.circular(20),
    ),
    child: ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        minimumSize: WidgetStateProperty.all<Size>(
          const Size(double.infinity, 60),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(primaryBlue),
        elevation: WidgetStateProperty.all<double>(0),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );
}
