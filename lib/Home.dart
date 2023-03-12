import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luttas_admin/imageAudies.dart';
import 'package:luttas_admin/main.dart';
import 'package:luttas_admin/usersAudios.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List allUsers=[];
  int _selectIndex=0;
  PageController _controller=PageController();

  getAllUsers()async{
    await FirebaseFirestore.instance.collection("Users").orderBy("userId").get().then((value) {
      allUsers=[];
      value.docs.forEach((element) {
        allUsers.add(element.data());
      });
   
      print(allUsers);
    });
  }





  Widget _buildImages(){
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.718),
        padding: const EdgeInsets.all(16),
        itemCount: 84,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagesAudios(imageId: index + 1),
                      ));
                },
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    child: Column(
                      children: [
                        Expanded(
                            child: Image.asset(
                              "images/${index + 1}.jpg",
                              fit: BoxFit.fill,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "ImageId: ${index + 1}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ))),
          );
        },
      ),
    );
  }

  Widget _buildUsers(){
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.718),
        padding: const EdgeInsets.all(16),
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersAudios(userId:allUsers[index]["userId"]),
                      ));
                },
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    child: Column(
                      children:  [
                        Expanded(
                            flex: 2,


                            child: Center(child: Text(allUsers[index]["userId"].toString(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),))),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              allUsers[index]["name"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "${allUsers[index]["age"]} Years",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ))),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    getAllUsers();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          _buildTopSelector(),
          Expanded(
            child: PageView.builder(
              onPageChanged: (value) {
                setState(() {
                  _selectIndex=value;
                });
              },
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                if(index==0){
                  return _buildImages();
                }else{
                  return _buildUsers();

                }
              },
            ),
          )
        ],
      ),
    );
  }

Widget  _buildTopSelector() {
    return Container(
      height: 60,
      margin:
      const EdgeInsets.only(top: 12, bottom: 0, right: 20, left: 20),
      child: Row(
          children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectIndex=0;
              });
              _controller.animateToPage(0, duration: const Duration(milliseconds: 350), curve: Curves.linear);

            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border:_selectIndex==0?null: Border.all(color: Colors.grey),
                  color: _selectIndex==0? Colors.blueAccent:Colors.white,

                  borderRadius: BorderRadius.circular(15)),
              child:  Center(
                child: Text(
                  "Images",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:_selectIndex==0? Colors.white:Colors.black),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectIndex=1;
              });
              _controller.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.linear);
            },
            child:
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  border:_selectIndex==1?null: Border.all(color: Colors.grey),
                  color: _selectIndex==1? Colors.blueAccent:Colors.white,

                  borderRadius: BorderRadius.circular(15)),
              child: Center(
                  child: Text(
                    "Users",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _selectIndex==1? Colors.white:Colors.black),
                  )),
            ),
          ),
        ),
      ]),
    );
  }
}
