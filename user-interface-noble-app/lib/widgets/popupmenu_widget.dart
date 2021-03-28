import 'package:flutter/material.dart';

Widget editPopUpMenuItem() {
  return PopupMenuItem(
    value: 1,
    child: Container(
      height: 35,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.green[500]),
          borderRadius: BorderRadius.circular(10),
          color: Colors.green[50]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.edit,
            color: Colors.lightGreen,
          ),
          Text(
            "Edit",
            style: TextStyle(
              fontFamily: 'RobotoBold',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget deletePopUpMenuItem() {
  return PopupMenuItem(
    value: 2,
    child: Container(
      height: 35,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.red[500]),
          borderRadius: BorderRadius.circular(10),
          color: Colors.red[50]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.delete,
            color: Colors.red,
          ),
          Center(
            child: Text(
              "Delete",
              style: TextStyle(
                fontFamily: 'RobotoBold',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
