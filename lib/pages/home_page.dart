import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test/pages/result_page.dart';

import '../constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();
  DateTime _birthday = DateTime.now();

  List<User> list = [];

  Future addUserToFB(
      {required String name,
      required String nickname,
      required DateTime birthday}) async {
    // Add a new document with random id to collection "User"
    final docUser = FirebaseFirestore.instance
        .collection('User'); // reference to collection "User"
    final json = {
      'id': docUser.id, // use id of document as id of user
      'name': name,
      'nickname': nickname,
      'birthday': birthday
    };
    await docUser.add(json);

    // Add a new document with id my-id to collection "User"
    // final docUser = FirebaseFirestore.instance.collection('User').doc("my-id"); // reference to document "my-id"
    // await docUser.set(json);
  }

  // Cách 1: dùng StreamBuilder để lấy dữ liệu từ Firebase
  // dùng cách này khi dữ liệu trên firebase thay đổi thì giao diện sẽ được refresh lại tức thì
  Stream<List<User>> getUserFromFBByFirstWay() {
    // tạo stream
    final docUser = FirebaseFirestore.instance
        .collection('User'); // reference to the document User

    // docUser.snapshots() to get list of all documents in collection User in json
    return docUser.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
      // doc.data() to get the data of document in json
    });
  }

  // Cách 2: đọc dữ liệu ra 1 list rồi xử lí
  getUserFromFBBySecondWay() async {
    final docUser = FirebaseFirestore.instance.collection('User');
    final snapshot = await docUser.get();
    list = snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  Future<User?> readUserByID() async {
    final docUser = FirebaseFirestore.instance.collection('User').doc("my-id");
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }
  }

  updateUser() {
    final docUser = FirebaseFirestore.instance.collection('User').doc("my-id");
    docUser.update({
      // 'name' : FieldValue.delete(), // delete a field of doc
      'name': 'Nguyen Van A',
      'nickname': 'NVA',
      'birthday': DateTime.now()
    });
  }

  delteUser() {
    final docUser = FirebaseFirestore.instance.collection('User').doc("my-id");
    docUser.delete();
  }

  @override
  void initState() {
    super.initState();
    getUserFromFBBySecondWay();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // _formField(
          //   context: context,
          //   label: "Name",
          //   hint: "Enter your name",
          //   controller: _nameController,
          // ),
          // _formField(
          //   context: context,
          //   label: "Nick name",
          //   hint: "Enter your nick name",
          //   controller: _nickNameController,
          // ),
          // _formField(
          //     context: context,
          //     label: _birthday.toString(),
          //     hint: "Enter your name",
          //     controller: _nameController,
          //     widget: InkWell(
          //         onTap: () => _getBirthdate(context: context),
          //         child: const Icon(Icons.arrow_drop_down_rounded, size: 32))),
          // ElevatedButton(
          //     onPressed: () {
          //       addUserToFB(
          //           name: _nameController.text,
          //           nickname: _nickNameController.text,
          //           birthday: _birthday);

          //       // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //       //   return const ResultPage();
          //       // }));
          //     },
          //     child: const Text("Next", style: TextStyle())),

          // dùng StreamBuilder để đưa stream vào listview
          Expanded(
            child: StreamBuilder<List<User>>(
                stream: getUserFromFBByFirstWay(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final users = snapshot.data!;

                    return ListView(
                      shrinkWrap: true,
                      children: users.map((user) {
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.nickName),
                          trailing: Text(user.birthday.toString()),
                        );
                      }).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ),

          // đưa dữ liệu trong list ra như bình thường
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(list[index].name),
                  subtitle: Text(list[index].nickName),
                  trailing: Text(list[index].birthday.toString()),
                );
              },
            ),
          ),

          // Dùng FutureBuilder để đưa 1 doc ra
          Expanded(
              child: FutureBuilder<User?>(
                  future: readUserByID(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final user = snapshot.data;

                      return user == null
                          ? const Center(child: Text('No user'))
                          : ListTile(
                              title: Text(user.name),
                              subtitle: Text(user.nickName),
                              trailing: Text(user.birthday.toString()),
                            );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }))
        ]),
      ),
    ));
  }

  _formField(
      {required BuildContext context,
      required String label,
      required String hint,
      required TextEditingController controller,
      Widget? widget}) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(10.0),
                // ),
                hintText: hint,
              ),
            ),
          ),
          widget ?? Container(),
        ],
      ),
    );
  }

  Future<void> _getBirthdate({required BuildContext context}) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }
}
