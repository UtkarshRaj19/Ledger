import 'package:flutter/material.dart';
import 'main.dart';
import 'add_debtor.dart';


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
                  Center(
                    child: _AmountBox(amount: totalDisbursedAmount),
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
  void refreshList(List<Map<String, dynamic>> updatedActiveDebtors, int updatedActiveDebtorsCount) {
    setState(() {
      widget.activeDebtors.clear();
      widget.activeDebtors.addAll(updatedActiveDebtors);
      widget.activeDebtorsCount = updatedActiveDebtorsCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              const Icon(
                Icons.account_circle, // Change to the appropriate user icon
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
                    String name = toTitleCase(debtor['Name']);
                    String mobile = debtor['Mobile'];

                    return Card(
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
class _AmountBox extends StatelessWidget {
  String amount;

  _AmountBox({required this.amount});

  @override
  Widget build(BuildContext context) {
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
            '₹',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}