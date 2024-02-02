import 'package:flutter/material.dart';
import 'main.dart';


// ignore: must_be_immutable
class ProfilePage1 extends StatelessWidget {
  int adminId;
  ProfilePage1({super.key, required this.adminId});

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
                    "Utkarsh Raj",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: _AmountBox(amount: 100),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _ScrollableList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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


class _ScrollableList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const int itemCount = 20;
    final List<Widget> listItems = List.generate(itemCount, (index) {
      int serialNumber = index + 1;
      String name = "Name $serialNumber";
      String mobile = "Mobile $serialNumber";

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.account_circle),
                Text('Name: $name'),
                Text('Mobile: $mobile'),
              ],
            ),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Icon(
                Icons.bookmark,
                color: Colors.blue, // Set the desired color
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Active Debtors',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Spacer(), // Added Spacer widget
              FloatingActionButton(
                onPressed: _handleFabPress,
              backgroundColor: Colors.blue,
              mini: true,
              child: Icon(Icons.add),
            ),
            ],
          ),
        ),
        Expanded(
          child: itemCount > 0
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: itemCount,
                  itemBuilder: (context, index) => listItems[index],
                )
              : const Center(
                  child: Text('No active Debtors'),
                ),
        ),
      ],
    );
  }
}

void _handleFabPress() {
}





class _AmountBox extends StatelessWidget {
  final int amount;

  const _AmountBox({required this.amount});

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
            '$amount',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}