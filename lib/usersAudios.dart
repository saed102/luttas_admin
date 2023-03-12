import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:luttas_admin/Home.dart';

class UsersAudios extends StatefulWidget {
  UsersAudios({super.key, required this.userId});

  var userId;

  @override
  State<UsersAudios> createState() => _UsersAudiosState();
}

class _UsersAudiosState extends State<UsersAudios> {
  int cIndex = -1;
  bool _isPlaying = false;
  bool idDownLoading = false;
  AudioPlayer _audioPlayer = AudioPlayer();

  late Duration _Duration = const Duration();
  late Duration _Postion = const Duration();
  List selectedItems = [];
  final List _audios = [];
  bool isFetching = false;

  @override
  void dispose() {
    _audioPlayer.release();

    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadDta();
    super.initState();
  }

  //
  // g() async {
  //   var res =
  //   await firebase_storage.FirebaseStorage.instance.ref("/1").listAll();
  //
  //   res.items.first.delete();// }



  deleteItems() async {
    setState(() {
      isUploading = true;
    });

    Iterable inReverse = selectedItems.reversed;
    await Future.forEach(inReverse, (item) async {
      await FirebaseFirestore.instance
          .collection("Audios")
          .doc("${item}_${widget.userId}")
          .delete().then((value) {
            print("$item is deleted");
      }).catchError((e){
        print("$item isn't deleted");
      });
      await firebase_storage.FirebaseStorage.instance.ref("/$item/${item}_${widget.userId}.wav").delete();
    });

    selectedItems.clear();

    await _loadDta();
  }

  _loadDta() async {
    setState(() {
      isFetching = true;
    });
    await FirebaseFirestore.instance
        .collection("Audios")
        .orderBy("ImageId")
        .get()
        .then((value) {
          _audios.clear();
      value.docs.forEach((element) {
        if (element.data()["UserId"] == widget.userId) {
          _audios.add(element.data());
        }
      });
      if (_audios.isNotEmpty) {
        print(_audios[0]);
      }
    });
    setState(() {
      isFetching = false;
      isUploading = false;
    });
  }

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
      await _audioPlayer.play(url).whenComplete(() {
        setState(() {
          idDownLoading = true;
        });
      });
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
          idDownLoading = false;
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

  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: selectedItems.isEmpty||isUploading  ? null : _buildBottoms(),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildBody(),
            if (isUploading)
              Container(
                color: Colors.black.withOpacity(0.4),
              ),
            if (isUploading) _buildLoadingCard()
          ],
        ));
  }

  Widget _buildLoadingCard() {
    return Center(
      child: Card(
        elevation: 10,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Expanded(
                child: Text(
              "الرجاء الانتظار جارى تحميل الصوت المسجل....",
              textDirection: TextDirection.rtl,
            )),
            SizedBox(
              width: 10,
            ),
            CircularProgressIndicator(),
          ]),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isFetching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_audios.isEmpty) {
      return const Center(child: Text("There are no Audios for this user",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w300),));
    }
    if (_audios.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: _audios.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          cIndex = index;
                          _Postion = const Duration(seconds: 0);
                          _isPlaying = false;
                        });
                        _onPlay(
                          url: _audios[index]["Audio"],
                        );
                      },
                      child: _buildAudioItem(index),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          )),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Select All",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            IconButton(
                onPressed: () {
                  if (_audios.length != selectedItems.length) {
                    _audios.forEach((element) {
                      if (selectedItems.contains(element["ImageId"])) {
                        print("contains");
                      } else {
                        selectedItems.add(element["ImageId"]);
                      }
                    });
                  } else {
                    selectedItems.clear();
                  }
                  print(selectedItems.length);
                  setState(() {});
                },
                icon: Icon(
                  _audios.length != selectedItems.length
                      ? Icons.check_box_outlined
                      : Icons.check_box_sharp,
                  color: Colors.green,
                )),
          ],
        ),
      ],
    );
  }

  deleteItem() async {
    selectedItems.forEach((element) async {
      print("${element}_${widget.userId}");
      await FirebaseFirestore.instance
          .collection("Audios")
          .doc("${element}_${widget.userId}")
          .delete();
    });
    print("object");
  }

  Widget _buildBottoms() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: (){
            _sure(true);
          },
          child: const Icon(Icons.delete),
        ),
        SizedBox(
          height: 15,
        ),
        FloatingActionButton(
          onPressed: (){},
          child: const Icon(Icons.download_rounded),
        ),
      ],
    );
  }

  Widget _buildAudioItem(index) {
    return Container(
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
              ListTile(
                trailing: IconButton(
                    onPressed: () {
                      if (selectedItems.contains(_audios[index]["ImageId"])) {
                        setState(() {
                          selectedItems.remove(_audios[index]["ImageId"]);
                        });
                      } else {
                        setState(() {
                          selectedItems.add(_audios[index]["ImageId"]);
                        });
                        print(selectedItems);
                      }
                    },
                    icon: selectedItems.contains(_audios[index]["ImageId"])
                        ? const Icon(
                            Icons.check_box,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.check_box_outlined,
                          )),
                title: Text(
                    "${_audios[index]["ImageId"]}_${_audios[index]["UserId"]}"),
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "${_audios[index]["UserId"]}",
                    style: TextStyle(fontSize: 18),
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
                            url: _audios[index]["Audio"],
                          );
                        },
                        icon:
                            Icon(_isPlaying ? Icons.pause : Icons.play_arrow)),
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
                    idDownLoading
                        ? Container(
                            height: 25,
                            width: 25,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Text(
                            "${_Postion.inHours}:${_Postion.inMinutes}:${_Postion.inSeconds.remainder(60)} / ${_Duration.inHours}:${_Duration.inMinutes}:${_Duration.inSeconds.remainder(60)}")
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void _sure(isDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
                onPressed: () {
                  if (isDelete) {
                    Navigator.pop(context);
                    deleteItems();
                  } else {
                    Navigator.pop(context);
                    // downloadItems();
                  }
                },
                child: const Text("Yes"))
          ],
          content: isDelete
              ? const Text(
            "Do you want to delete items?",
            textAlign: TextAlign.center,
          )
              : const Text(
            "Do you want to download items?",
            textAlign: TextAlign.center,
          ),
          elevation: 10,
        );
      },
    );
  }

}
