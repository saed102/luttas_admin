
import 'package:flutter/material.dart';
import 'package:luttas_admin/imageAudies.dart';
import 'package:luttas_admin/main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.718),
        padding: EdgeInsets.all(16),
        itemCount: 84,
        itemBuilder: (context, index) {
        return  Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
              onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context) => MyHomePage(title: index+1),) );

              },
              child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                  elevation: 10,
                  child: Column(
                    children: [
                      Expanded(child: Image.asset("images/${index+1}.jpg",fit: BoxFit.fill,)),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("ImageId: ${index+1}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ))),
        );
      },),
    );
  }
}
