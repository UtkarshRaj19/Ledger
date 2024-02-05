// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
// import 'package:ledger/home_screen.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'app_state_notifier.dart';


// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  int adminId;
  int debtorId;
  String debtorName;
  String debtorNumber;
  int loanAmount;
  int paidAmount;
  int balanceAmount;
  List<Map<String, dynamic>> transactions;
  Dashboard({super.key , required this.debtorId , required this.debtorName , required this.debtorNumber , required this.loanAmount , required this.paidAmount , required this.balanceAmount , required this.transactions, required this.adminId});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late AppState appState;

  void _showAddTransactionPopup() {
    final appState = context.read<AppState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(
          onAddTransaction: (amount, type, remark) {
            final disbursementData = DisbursementData();
            _processTransaction(context,widget.adminId,widget.debtorId,amount, type, remark,disbursementData,appState);
          },
        );
      },
    );
  }

  void _processTransaction(BuildContext context, int adminId, int debtorId, String amount, String type, String remark, DisbursementData disbursementData,AppState appState) async {
    const String apiUrl = 'https://wpoc2ga7ki.execute-api.ap-southeast-1.amazonaws.com/dev/v1/AddDebtorTransaction';
    try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'AdminID': adminId.toString(),
            'DebtorID': debtorId.toString(),
            'Amount': amount,
            'TransactionType': type,
            'Remark': remark,
          },
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['status'] == true){
            Fluttertoast.showToast(
              msg: "Transaction Inserted Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            int loanAmount = responseData['LoanAmount'];
            int paidAmount = responseData['PaidAmount'];
            // int balanceAmount = responseData['BalanceAmount'];
            String totalDisbursedAmount = responseData['TotalDisbursedAmount'];
            List<Map<String, dynamic>> updatedTransactions = (responseData['Transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            disbursementData.updateTransactions(appState,updatedTransactions.length,updatedTransactions);
            disbursementData.updateDisbursedAmount(appState,totalDisbursedAmount);
            disbursementData.updateAmountBox(appState,loanAmount,paidAmount);
          }
          else{
            Fluttertoast.showToast(
              msg: "Transaction Insertion Failed",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
          } else {
          Fluttertoast.showToast(
              msg: "Some Error Occoured",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
        }
      } catch (e) {
        Fluttertoast.showToast(
              msg: "Server Error",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
      }
  }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Debtor Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [          
          Container(
            height: 205,
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.debtorName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.debtorNumber,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const CircularBalanceDisplay(),
                  ],
                ),
                const Spacer(),
                const AmountWidget(),
              ],
            ),
          ),
          // SizedBox(height: 20),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  const Icon(Icons.bookmark, color: Colors.black),
                  const Text(
                    "Transactions",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Spacer
                  const Spacer(),
                  // Add floating action button
                  FloatingActionButton(
                    onPressed: () {
                      _showAddTransactionPopup();
                    },
                    mini: true,
                    heroTag: UniqueKey(),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            ScrollableListWidget(debtorId: widget.debtorId,adminId: widget.adminId),
          ],
        ),
      );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(String, String, String) onAddTransaction;

  const AddTransactionDialog({super.key, required this.onAddTransaction});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  String? transactionType;
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  bool get isMounted => mounted;

  bool isAddButtonEnabled() {
    return amountController.text.isNotEmpty &&
        remarkController.text.isNotEmpty &&
        transactionType != null &&
        isMounted;
  }

  @override
  void dispose() {
    amountController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Transaction"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Amount is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: remarkController,
            decoration: const InputDecoration(labelText: 'Remark'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Remark is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // const Text('Transaction Type:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio(
                    value: 'Credit',
                    groupValue: transactionType,
                    onChanged: (value) {
                      if (isMounted) {
                        setState(() {
                          transactionType = value;
                        });
                      }
                    },
                  ),
                  const Text('Credit'),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Radio(
                    value: 'Debit',
                    groupValue: transactionType,
                    onChanged: (value) {
                      if (isMounted) {
                        setState(() {
                          transactionType = value;
                        });
                      }
                    },
                  ),
                  const Text('Debit'),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (isMounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isAddButtonEnabled()
              ? () {
                  if (isMounted) {
                    // Perform your logic to add the transaction
                    // You can access entered values using amountController.text,
                    // transactionType, remarkController.text
                    widget.onAddTransaction(
                      amountController.text,
                      transactionType!,
                      remarkController.text,
                    );
                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: const Text("Add"),
        ),
      ],
    );
  }
}

class ScrollableListWidget extends StatefulWidget {
  final int debtorId;
  final int adminId;
  const ScrollableListWidget({super.key , required this.debtorId , required this.adminId});

  @override
  _ScrollableListWidgetState createState() => _ScrollableListWidgetState();
}

class _ScrollableListWidgetState extends State<ScrollableListWidget> {

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final appStateWrite = context.read<AppState>();
    final disbursementData = DisbursementData();

    return Expanded(
      child: appState.transactionCount == 0
          ? const Center(
              child: Text(
                "No Transactions",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: appState.transactionCount,
              itemBuilder: (BuildContext context, int index) {
                bool isCredit = appState.itemList[index]['TransactionType'] == 'Credit';
                String transactionType = isCredit ? "Credit" : "Debit";
                String dateTime = appState.itemList[index]['CreatedAt'];
                int amount = isCredit
                    ? appState.itemList[index]['Amount']
                    : -appState.itemList[index]['Amount'];
                  return Dismissible(
                    key: Key(appState.itemList[index]['ID'].toString()),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text("Are you sure you want to delete this transaction?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("No"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        // print("dismissed successfully");
                        deleteTransaction(appStateWrite,context,appState.itemList[index]['ID'].toString(),widget.debtorId,widget.adminId,disbursementData);
                      }
                    },
                  child:GestureDetector(
                  onTap: () {
                    _showTransactionDetails(index , appState.itemList);
                  },
                  child: Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                    color: isCredit ? Colors.green : Colors.redAccent,
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transactionType,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  dateTime,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${amount > 0 ? '+' : ''}$amount",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                );
              },
            ),
    );
  }
  void _showTransactionDetails(int index , List<Map<String, dynamic>> itemList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: "Type: ",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                    ),
                    TextSpan(
                      text: "${itemList[index]['TransactionType']}",
                    ),
                  ],
                ),
              ),
                RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: "Amount: ",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                    ),
                    TextSpan(
                      text: "${itemList[index]['Amount']}",
                    ),
                  ],
                ),
              ),
                RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: "Date: ",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                    ),
                    TextSpan(
                      text: "${itemList[index]['CreatedAt']}",
                    ),
                  ],
                ),
              ),
                RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: "Remark: ",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                    ),
                    TextSpan(
                      text: "${itemList[index]['Remarks']}",
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void deleteTransaction(AppState appState,BuildContext context, transactionId,int debtorId,int adminId,DisbursementData disbursementData) async {
  const String apiUrl = 'https://wpoc2ga7ki.execute-api.ap-southeast-1.amazonaws.com/dev/v1/DeleteDebtorTransaction';
    try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'DebtorID': debtorId.toString(),
            'TransactionID': transactionId,
            'AdminID': adminId.toString(),
          },
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['status'] == true){
            Fluttertoast.showToast(
              msg: "Transaction Deleted Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            int loanAmount = responseData['LoanAmount'];
            int paidAmount = responseData['PaidAmount'];
            String totalDisbursedAmount = responseData['TotalDisbursedAmount'];
            List<Map<String, dynamic>> updatedTransactions = (responseData['Transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            disbursementData.updateTransactions(appState,updatedTransactions.length,updatedTransactions);
            disbursementData.updateDisbursedAmount(appState,totalDisbursedAmount);
            disbursementData.updateAmountBox(appState,loanAmount,paidAmount);
          }
          else{
            Fluttertoast.showToast(
              msg: "Transaction Deletion Failed",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
          } else {
          Fluttertoast.showToast(
              msg: "Some Error Occoured",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
        }
      } catch (e) {
        Fluttertoast.showToast(
              msg: "Server Error",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
      }
}
}


class AmountWidget extends StatefulWidget {

  const AmountWidget({super.key});

  @override
  
  _AmountWidgetState createState() => _AmountWidgetState();
}

class _AmountWidgetState extends State<AmountWidget> {
  late int amountTaken;
  late int amountPaid;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    int balance = appState.amountTaken - appState.amountPaid;
    String balanceText = balance >= 0 ? "Balance" : "Advanced";
    int balanceAmount = appState.amountTaken - appState.amountPaid >=0 ? appState.amountTaken - appState.amountPaid :  appState.amountPaid - appState.amountTaken;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Loan Amount",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              color: Colors.red,
              margin: const EdgeInsets.only(right: 6),
            ),
            Text(
              "${appState.amountTaken}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          "Paid Amount",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              color: Colors.lightGreen,
              margin: const EdgeInsets.only(right: 6),
            ),
            Text(
              "${appState.amountPaid}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          balanceText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              color: Colors.orange,
              margin: const EdgeInsets.only(right: 6),
            ),
            Text(
              "$balanceAmount",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class CircularBalanceDisplay extends StatefulWidget {
  const CircularBalanceDisplay({
    super.key,
  });

  @override
  _CircularBalanceDisplayState createState() => _CircularBalanceDisplayState();
}

class _CircularBalanceDisplayState extends State<CircularBalanceDisplay> {

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    double percentagePaid = appState.amountPaid / appState.amountTaken;
    percentagePaid = percentagePaid.clamp(0.0, 1.0);
    return Center(
      child: SizedBox(
        height: 100,
        width: 150,
        child: CustomPaint(
          painter: CircularBalancePainter(percentagePaid),
        ),
      ),
    );
  }
}

class CircularBalancePainter extends CustomPainter {
  final double percentagePaid;

  CircularBalancePainter(this.percentagePaid);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = min(size.width / 2, size.height / 2);
    double strokeWidth = 15;

    Paint outlinePaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint filledPaint = Paint()
      ..color = Colors.lightGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius - strokeWidth / 2, outlinePaint);

    double sweepAngle = 360 * percentagePaid;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius - strokeWidth / 2),
      -90.0 * (pi / 180.0),
      sweepAngle * (pi / 180.0),
      false,
      filledPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DisbursementData {
  String mainDisbursedAmount = "";

  void updateDisbursedAmount(AppState appState,String newAmount) {
    appState.setTotalDisbursedAmount(newAmount);
    mainDisbursedAmount = newAmount;
  }

  void updateTransactions(AppState appState,int transactionsCount,List<Map<String, dynamic>> transactions) {
    appState.setTransactions(transactionsCount,transactions);
  }

  void updateAmountBox(AppState appState,int newamountTaken,int newAmountPaid) {
    appState.setAmountBox(newamountTaken,newAmountPaid);
  }
}