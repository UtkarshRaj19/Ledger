import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

_AmountWidgetState? globalAmountWidgetState;
_ScrollableListWidgetState? globalScrollWidgetState;

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
  // ignore: library_private_types_in_public_api
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void _showAddTransactionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(
          onAddTransaction: (amount, type, remark) {
            // print('adminId: ${widget.adminId}, DebtorId: ${widget.debtorId}, Amount: $amount, Type: $type, Remark: $remark');
            _processTransaction(widget.adminId,widget.debtorId,amount, type, remark);
          },
        );
      },
    );
  }

  void _processTransaction(int adminId,int debtorId,String amount, String type, String remark) async {
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
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            int loanAmount = responseData['LoanAmount'];
            int paidAmount = responseData['PaidAmount'];
            // int balanceAmount = responseData['BalanceAmount'];
            // String totalDisbursedAmount = responseData['TotalDisbursedAmount'];
            List<Map<String, dynamic>> updatedTransactions = (responseData['Transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            AmountWidget.getGlobalInstance()?.updateAmounts(loanAmount, paidAmount);
            ScrollableListWidget.getGlobalInstance()?.updateValues(updatedTransactions, updatedTransactions.length);
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
                    CircularBalanceDisplay(amountTaken: widget.loanAmount, amountPaid: widget.paidAmount),
                  ],
                ),
                const Spacer(),
                AmountWidget(
                initialAmountTaken: widget.loanAmount,
                initialAmountPaid: widget.paidAmount,
                onWidgetCreated: () {
                  // The widget has been created, now you can access its state
                  AmountWidget.getGlobalInstance()?.updateAmounts(widget.loanAmount, widget.paidAmount);
                },
              ),
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
            // ScrollableListWidget(itemList:widget.transactions,transactionCount:widget.transactions.length),
            ScrollableListWidget(initialItemList:widget.transactions,initialTransactionCount:widget.transactions.length,
                onScrollWidgetCreated: () {
                  // The widget has been created, now you can access its state
                  ScrollableListWidget.getGlobalInstance()?.updateValues(widget.transactions, widget.transactions.length);
                },
              ),
          ],
        ),
      );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(String, String, String) onAddTransaction;

  const AddTransactionDialog({super.key, required this.onAddTransaction});

  @override
  // ignore: library_private_types_in_public_api
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

// ignore: must_be_immutable
class ScrollableListWidget extends StatefulWidget {
  List<Map<String, dynamic>> initialItemList;
  int initialTransactionCount;
  Function? onScrollWidgetCreated;

  ScrollableListWidget({super.key, required this.initialItemList, required this.initialTransactionCount , required this.onScrollWidgetCreated});

  @override
  // ignore: library_private_types_in_public_api
  _ScrollableListWidgetState createState() => _ScrollableListWidgetState();
  // ignore: library_private_types_in_public_api
  static _ScrollableListWidgetState? getGlobalInstance() {
    return globalScrollWidgetState;
  }
}

class _ScrollableListWidgetState extends State<ScrollableListWidget> {
  late List<Map<String, dynamic>> itemList;
  late int transactionCount;

  @override
  void initState() {
    super.initState();
    itemList = widget.initialItemList;
    transactionCount = widget.initialTransactionCount;
    globalScrollWidgetState = this;
    widget.onScrollWidgetCreated?.call();
  }

  void updateValues(List<Map<String, dynamic>> newItemList, int newTransactionCount) {
    print("*********************************updateValues*****************************************");
    setState(() {
      itemList = newItemList;
      transactionCount = newTransactionCount;
    });
  }

  void _showTransactionDetails(int index) {
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: transactionCount == 0
          ? const Center(
              child: Text(
                "No Transactions",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: transactionCount,
              itemBuilder: (BuildContext context, int index) {
                bool isCredit = itemList[index]['TransactionType'] == 'Credit';
                String transactionType = isCredit ? "Credit" : "Debit";
                String dateTime = itemList[index]['CreatedAt'];
                int amount = isCredit
                    ? itemList[index]['Amount']
                    : -itemList[index]['Amount'];
                return GestureDetector(
                  onTap: () {
                    _showTransactionDetails(index);
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
                );
              },
            ),
    );
  }
}


class AmountWidget extends StatefulWidget {
  final int initialAmountTaken;
  final int initialAmountPaid;
  final Function? onWidgetCreated;

  const AmountWidget({super.key, 
    required this.initialAmountTaken,
    required this.initialAmountPaid,
    this.onWidgetCreated,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AmountWidgetState createState() => _AmountWidgetState();

  // ignore: library_private_types_in_public_api
  static _AmountWidgetState? getGlobalInstance() {
    return globalAmountWidgetState;
  }
}

class _AmountWidgetState extends State<AmountWidget> {
  late int amountTaken;
  late int amountPaid;

  @override
  void initState() {
    super.initState();
    amountTaken = widget.initialAmountTaken;
    amountPaid = widget.initialAmountPaid;
    // Set the global instance when the state is created
    globalAmountWidgetState = this;

    // Notify the global instance that it's ready
    widget.onWidgetCreated?.call();
  }

  void updateAmounts(int newAmountTaken, int newAmountPaid) {
    setState(() {
      amountTaken = newAmountTaken;
      amountPaid = newAmountPaid;
    });
  }

  @override
  Widget build(BuildContext context) {
    int balance = amountTaken - amountPaid;
    String balanceText = balance >= 0 ? "Balance" : "Advanced";
    int balanceAmount = amountTaken - amountPaid >=0 ? amountTaken - amountPaid :  amountPaid - amountTaken;
    // widget.onWidgetCreated?.call();
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
              "$amountTaken",
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
              "$amountPaid",
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

class CircularBalanceDisplay extends StatelessWidget {
  final int amountTaken;
  final int amountPaid;

  const CircularBalanceDisplay({
    super.key,
    required this.amountTaken,
    required this.amountPaid,
  });

  @override
  Widget build(BuildContext context) {
    double percentagePaid = amountPaid / amountTaken;
    // print("percentagePaid: $percentagePaid amountPaid: $amountPaid amountTaken: $amountTaken");

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
  double percentagePaid;

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

    // Limit the percentagePaid to the valid range (0-100%)
    percentagePaid = percentagePaid.clamp(0.0, 1.0);

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

class AmountProvider extends ChangeNotifier {
  int _amountTaken = 0;
  int _amountPaid = 0;

  int get amountTaken => _amountTaken;
  int get amountPaid => _amountPaid;

  void updateAmounts(int newAmountTaken, int newAmountPaid) {
    _amountTaken = newAmountTaken;
    _amountPaid = newAmountPaid;
    notifyListeners();
  }
}