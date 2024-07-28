//return formatted data as a string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  //Timestamp is the object received from firebase
  //display as a string
  DateTime dateTime = timestamp.toDate();

  //get year
  String year = dateTime.year.toString();

  //get month
  String month = dateTime.month.toString();

  //get day
  String day = dateTime.day.toString();

  //final formatted date
  String formattedDate = '$day/$month/$year';

  return formattedDate;
}
