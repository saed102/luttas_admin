import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:luttas_admin/Home.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  int title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void dispose() {
    _audioPlayer.release();

    _audioPlayer.dispose();
    super.dispose();
  }
  @override
  void initState() {
    d();
    super.initState();
  }


 List deleteItems=[];

  g() async {
    var res =
        await firebase_storage.FirebaseStorage.instance.ref("/1").listAll();

    res.items.first.delete();
  }

  List d1 = [];
  bool isFetching = false;

  d() async {
    setState(() {
      isFetching = true;
    });
    await FirebaseFirestore.instance
        .collection("Audios")
        .where("ImageId", isEqualTo: widget.title)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        d1.add(element.data());
      });
      if (d1.isNotEmpty) {
        print(d1[0]);

        d1.sort(
          (a, b) => a["ImageId"].compareTo(b["ImageId"]),
        );
      }
    });
    setState(() {
      isFetching = false;
    });
  }

  int cIndex = -1;
  bool _isPlaying = false;
  AudioPlayer _audioPlayer = AudioPlayer();


  late Duration _Duration = const Duration();
  late Duration _Postion = const Duration();

  Future<void> _onPlay({
    required String url,
  }) async {
    if (_isPlaying) {

      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play(url);
      setState(() {
        _isPlaying = true;
        _Postion = const Duration(seconds: 0);
      });
      _audioPlayer.onAudioPositionChanged.listen((event) {
        setState(() {
          _Postion = event;
        });
      });
      _audioPlayer.onDurationChanged.listen((event) {
        setState(() {
          _Duration = event;
        });
      });
      _audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          _isPlaying = false;
          _Postion = const Duration(seconds: 0);
        });
      });
    }
  }

  _seek(int s) async {
    Duration newDuration = Duration(seconds: s);
    await _audioPlayer.seek(newDuration);
    setState(() {});
  }

  Widget _buildBody() {
    if (isFetching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (d1.isEmpty) {
      return const Center(child: Text("No Audios Founded"));
    }
    if (d1.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Select All"),
                  IconButton(onPressed: (){
                    if(d1.length!=deleteItems.length){
                      d1.forEach((element) {
                        if(deleteItems.contains(element["Audio"])){
                          print("contains");
                        }else{
                          deleteItems.add(element["Audio"]);

                        }
                      });
                    }else{
                      deleteItems.clear();
                    }
                    print(deleteItems.length);
                    setState(() {

                    });
                  }, icon: Icon(d1.length!=deleteItems.length? Icons.check_box_outlined:Icons.check_box_sharp,color: Colors.green,)),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: d1.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          cIndex = index;
                          _Postion=const Duration(seconds: 0);
                          _isPlaying=false;
                        });
                        _onPlay(
                          url: d1[index]["Audio"],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(14)),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(child: Text("Name: mohamed said")),

                                const Center(child: Text("Age: 25")),
                                const Center(child: Text("Country: Egypt")),
                                const SizedBox(height: 10,),
                                ListTile(

                                  trailing: IconButton(
                                      onPressed: () {
                                        if(deleteItems.contains(d1[index]["Audio"])){
                                          setState(() {
                                            deleteItems.remove(d1[index]["Audio"]);
                                          });
                                        }else{
                                          setState(() {
                                            deleteItems.add(d1[index]["Audio"]);
                                          });
                                        }

                                      },
                                      icon:deleteItems.contains(d1[index]["Audio"])?const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ): const Icon(
                                        Icons.check_circle_outline,
                                      )),
                                  title: Text(
                                      "${d1[index]["ImageId"]}_${d1[index]["UserId"]}"),
                                  leading: CircleAvatar(
                                    maxRadius: 50,
                                    backgroundImage: AssetImage(
                                      "images/${widget.title}.jpg",
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (cIndex == index)
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            _onPlay(
                                              url: d1[index]["Audio"],
                                            );
                                          },
                                          icon: Icon(_isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow)),
                                      Expanded(
                                        child: Slider(
                                            value: cIndex == index
                                                ? _Postion.inSeconds.toDouble()
                                                : 0,
                                            min: 0.0,
                                            max: _Duration.inSeconds.toDouble(),
                                            onChanged: (v) {
                                              _seek(v.toInt());
                                            }),
                                      ),
                                      Text(
                                          "${_Postion.inHours}:${_Postion.inMinutes}:${_Postion.inSeconds.remainder(60)} / ${_Duration.inHours}:${_Duration.inMinutes}:${_Duration.inSeconds.remainder(60)}")
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton:deleteItems.isEmpty?null: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(onPressed: (){},child: const Icon(Icons.delete),),
          SizedBox(height: 15,),
          FloatingActionButton(onPressed: (){},child: const Icon(Icons.download_rounded),),
        ],
      ),
        appBar: AppBar(
          title: InkWell(onTap: () async {}, child: const Text("")),
        ),
        body: _buildBody());
  }
}
