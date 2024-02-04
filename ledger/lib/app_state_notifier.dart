import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _totalDisbursedAmount = '0';
  int _transactionCount = 0;
  int _amountPaid = 0;
  int _amountTaken = 0;
  List<Map<String, dynamic>> _itemList = [];

  String get totalDisbursedAmount => _totalDisbursedAmount;
  int get transactionCount => _transactionCount;
  int get amountTaken => _amountTaken;
  int get amountPaid => _amountPaid;
  List<Map<String, dynamic>> get itemList => _itemList;

  void setTotalDisbursedAmount(String newAmount) {
    _totalDisbursedAmount = newAmount;
    notifyListeners();
  }

  void setTransactions(int newTransactionCount , List<Map<String, dynamic>> newItemList) {
    _transactionCount = newTransactionCount;
    _itemList = newItemList;
    notifyListeners();
  }

  void setAmountBox(int newamountTaken , int newAmountPaid) {
    _amountTaken = newamountTaken;
    _amountPaid = newAmountPaid;
    notifyListeners();
  }
}