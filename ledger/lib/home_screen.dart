// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'main.dart';
import 'add_debtor.dart';
import 'app_state_notifier.dart';
import 'debtor_profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class ProfilePage1 extends StatelessWidget {
  int adminId;
  String adminName;
  String totalDisbursedAmount;
  int activeDebtorsCount;
  List<Map<String, dynamic>> activeDebtors;
  // ProfilePage1({super.key, required this.adminId , required this.adminName , required this.activeDebtors , required this.activeDebtorsCount});
  ProfilePage1({super.key, 
    required this.adminId,
    required this.adminName,
    required this.activeDebtors,
    required this.activeDebtorsCount,
    required this.totalDisbursedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    adminName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: AmountBox(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _ScrollableList(activeDebtors: activeDebtors,
                                          activeDebtorsCount: activeDebtorsCount,
                                          adminId:adminId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: UniqueKey(),
        key: GlobalKey(debugLabel: 'LogoutFloatingButton'),
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        backgroundColor: Colors.blue,
        mini: true,
        child: const Icon(Icons.logout),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                )
              );
            },
            child: const Text("Ok"),
          ),
        ],
      );
    },
  );
}



class _TopPortion extends StatelessWidget {
  const _TopPortion();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xff0043ba), Color(0xff006df1)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
Positioned(
  top: MediaQuery.of(context).padding.top + 10, // Consider the status bar height
  left: 0,
  right: 0,
  child: SafeArea(
    child: Center(
      child: Image.asset(
        'assets/ledger_banner.png', // Replace with your image path
        // width: 60,
        height: 70,
      ),
    ),
  ),
),


        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/headshot.jpg'),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



// ignore: must_be_immutable
class _ScrollableList extends StatefulWidget {
  final List<Map<String, dynamic>> activeDebtors;
  int activeDebtorsCount;
  final int adminId;

  _ScrollableList({
    required this.activeDebtors,
    required this.activeDebtorsCount,
    required this.adminId,
  });

  @override
  _ScrollableListState createState() => _ScrollableListState();
}

class _ScrollableListState extends State<_ScrollableList> {
  bool isNavigationInProgress = false;
  void refreshList(List<Map<String, dynamic>> updatedActiveDebtors, int updatedActiveDebtorsCount) {
    setState(() {
      widget.activeDebtors.clear();
      widget.activeDebtors.addAll(updatedActiveDebtors);
      widget.activeDebtorsCount = updatedActiveDebtorsCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final debtorData = DebtorData();
    BuildContext storedContext = context;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              const Icon(
                Icons.bookmark,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Debtors',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) => FloatingActionButton(
                  heroTag: UniqueKey(),
                  onPressed: () => _handleFabPress(context),
                  backgroundColor: Colors.blue,
                  mini: true,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.activeDebtorsCount  > 0
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.activeDebtorsCount,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> debtor = widget.activeDebtors[index];
                    int adminId = debtor['AdminID'];
                    int debtorId = debtor['ID'];
                    String name = toTitleCase(debtor['Name']);
                    String mobile = debtor['Mobile'];
                    String address = debtor['Address'];
                    
                    return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.transparent, // Swipe left background color
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 10),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    secondaryBackground: Container(
                      color: Colors.transparent, // Swipe right background color
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 10),
                      child: const Icon(Icons.edit, color: Colors.orange),
                    ),
                    confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Swipe left (edit)
                      _showEditPopup(context,adminId,debtorId, name , mobile,address,refreshList);
                      return false; // Do not dismiss immediately
                    } else if (direction == DismissDirection.startToEnd) {
                      // Swipe right (delete)
                      bool shouldDelete = await _showDeleteConfirmationDialog(context,name);
                      if (shouldDelete) {
                        print("Debtor Deleted");
                        _deleteDebtorAPI(adminId , debtorId ,appState,debtorData, refreshList);
                      } else {
                        return false; // Do not dismiss if user cancels
                      }
                    }
                    return true; // Allow other directions to dismiss
                  },
                    child:GestureDetector(
                      onTap: () async {
                        if (!isNavigationInProgress) {
                        isNavigationInProgress = true;
                        const String apiUrl = 'https://wpoc2ga7ki.execute-api.ap-southeast-1.amazonaws.com/dev/v1/DebtorDetailyById';
                        try {
                          final response = await http.post(
                            Uri.parse(apiUrl),
                            body: {
                              'DebtorID': debtorId.toString(),
                            },
                          );
                          if (response.statusCode == 200) {
                            Map<String, dynamic> responseData = json.decode(response.body);
                            if (responseData['status'] == true){
                              // Fluttertoast.showToast(
                              // msg: "Debtor $debtorId Clicked !!!",
                              // toastLength: Toast.LENGTH_SHORT,
                              // gravity: ToastGravity.BOTTOM,
                              // timeInSecForIosWeb: 2,
                              // backgroundColor: Colors.red,
                              // textColor: Colors.white,
                              // );
                              int loanAmount = responseData['LoanAmount'];
                              int paidAmount = responseData['PaidAmount'];
                              int balanceAmount = responseData['BalanceAmount'];
                              List<Map<String, dynamic>> transactions = (responseData['Transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                              debtorData.updateTransactions(appState, transactions.length, transactions);
                              debtorData.updateAmountBox(appState, loanAmount, paidAmount);
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                storedContext,
                                MaterialPageRoute(builder: (context) => Dashboard(
                                debtorId: debtorId,debtorName: name,debtorNumber: mobile,
                                loanAmount: loanAmount, paidAmount: paidAmount,balanceAmount: balanceAmount,
                                transactions: transactions , adminId:widget.adminId
                              )
                              ),
                              );
                              isNavigationInProgress = false;
                            }
                            else{
                              Fluttertoast.showToast(
                                msg: "Error Getting Debtor Details",
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
                      },
                      child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Color.fromARGB(255, 11, 131, 119)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.account_circle),
                              const SizedBox(width: 15),
                              Text(name),
                              const Spacer(),
                              Text(mobile),
                            ],
                          ),
                        ),
                      ),
                      ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('No active Debtors'),
                ),
        ),
      ],
    );
  }
  void _handleFabPress(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddDebtorPopup(adminId: widget.adminId, onDebtorAdded: refreshList);
      },
    );
  }
  Future<bool> _showDeleteConfirmationDialog(BuildContext context, String name) async {
  bool result = (await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Delete
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  )) ?? false; // Default to false if result is null

  return result;
}

void _showEditPopup(BuildContext context,int adminId,int debtorId, String name, String mobile, String address,Function(List<Map<String, dynamic>>, int) onDebtorAdded) {
  TextEditingController nameController = TextEditingController(text: name);
  TextEditingController mobileController = TextEditingController(text: mobile);
  TextEditingController addressController = TextEditingController(text: address);

  bool hasChanges = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Edit Debtor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    setState(() {
                      hasChanges = value.trim() != name.trim();
                    });
                  },
                ),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  onChanged: (value) {
                    setState(() {
                      hasChanges = value.trim() != mobile.trim();
                    });
                  },
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  onChanged: (value) {
                    setState(() {
                      hasChanges = value.trim() != address.trim();
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: hasChanges
                    ? () {
                        String updatedName = nameController.text;
                        String updatedMobile = mobileController.text;
                        String updatedAddress = addressController.text;
                        if (updatedMobile.length == 10) {
                          print("Name:$updatedName Mobile:$updatedMobile Address:$updatedAddress");
                          _updateDebtorAPI(adminId , debtorId ,updatedName, updatedMobile , updatedAddress , onDebtorAdded);
                          Navigator.of(context).pop(); // Close the popup
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Mobile number should be 10 digits'),
                          ));
                        }
                      }
                    : null,
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    },
  );
}
Future<void> _deleteDebtorAPI(int adminId,int debtorId,AppState appState,DebtorData debtorData,Function(List<Map<String, dynamic>>, int) onDebtorAdded) async {
  const String apiUrl = 'https://wpoc2ga7ki.execute-api.ap-southeast-1.amazonaws.com/dev/v1/DeleteDebtor';
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "AdminID": adminId.toString(),
        "DebtorID":debtorId.toString()
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == true){
        Fluttertoast.showToast(
          msg: "Debtor Deletion Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        List<Map<String, dynamic>> newDebtors = (responseData['ActiveDebtors'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        String totalDisbursedAmount = responseData['TotalDisbursedAmount'];
        onDebtorAdded(newDebtors, responseData['ActiveDebtorsCount']);
        debtorData.updateTotalDisbursedAmount(appState, totalDisbursedAmount);
      }
      else{
        Fluttertoast.showToast(
          msg: "Debtor Deletion Failed",
          toastLength: Toast.LENGTH_SHORT,
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
Future<void> _updateDebtorAPI(int adminId,int debtorId,String name , String mobile, String address,Function(List<Map<String, dynamic>>, int) onDebtorAdded) async {
  const String apiUrl = 'https://wpoc2ga7ki.execute-api.ap-southeast-1.amazonaws.com/dev/v1/UpdateDebtor';
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "AdminID": adminId.toString(),
        "DebtorID":debtorId.toString(),
        "Name":name,
        "Mobile":mobile,
        "Address":address
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == true){
        Fluttertoast.showToast(
          msg: "Debtor Updation Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        List<Map<String, dynamic>> newDebtors = (responseData['ActiveDebtors'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        onDebtorAdded(newDebtors, responseData['ActiveDebtorsCount']);
      }
      else{
        Fluttertoast.showToast(
          msg: "Debtor Updation Failed",
          toastLength: Toast.LENGTH_SHORT,
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


// void _handleFabPress() {
// }

String toTitleCase(String text) {
  return text.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1);
    } else {
      return '';
    }
  }).join(' ');
}

// ignore: must_be_immutable
class AmountBox extends StatefulWidget {

  const AmountBox({super.key});

  @override
  _AmountBoxState createState() => _AmountBoxState();
}

class _AmountBoxState extends State<AmountBox> {

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '₹ ',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            appState.totalDisbursedAmount,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class DebtorData {
  void updateTransactions(AppState appState,int transactionsCount,List<Map<String, dynamic>> transactions) {
    appState.setTransactions(transactionsCount,transactions);
  }

  void updateAmountBox(AppState appState,int newamountTaken,int newAmountPaid) {
    appState.setAmountBox(newamountTaken,newAmountPaid);
  }

  void updateTotalDisbursedAmount(AppState appState,String totalDisbursedAmount) {
    appState.setTotalDisbursedAmount(totalDisbursedAmount);
  }
}