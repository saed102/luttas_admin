import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:luttas_admin/Home.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagesAudios extends StatefulWidget {
  ImagesAudios({super.key, required this.imageId});

  var imageId;

  @override
  State<ImagesAudios> createState() => _ImagesAudiosState();
}

class _ImagesAudiosState extends State<ImagesAudios> {
  int cIndex = -1;
  bool _isPlaying = false;
  AudioPlayer _audioPlayer = AudioPlayer();

  late Duration _Duration = const Duration();
  late Duration _Postion = const Duration();
  List selectedItems = [];
  final List _audios = [];
  bool isFetching = false;

  @override
  void dispose() {
    _audioPlayer.release();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    dd();

    _loadDta();
    super.initState();
  }


  dd()async{
    if (await Permission.contacts.request().isGranted) {
     print("object");
    }else{
      print("21");
    }

  }
  //
  // g() async {
  //   var res =
  //   await firebase_storage.FirebaseStorage.instance.ref("/1").listAll();
  //
  //   res.items.first.delete();
  // }

  deleteItems() async {
    setState(() {
      isUploading = true;
    });

    Iterable inReverse = selectedItems.reversed;
    await Future.forEach(inReverse, (item) async {
      await FirebaseFirestore.instance
          .collection("Audios")
          .doc("${widget.imageId}_${item}")
          .delete()
          .then((value) {
        print("$item is deleted");
      }).catchError((e) {
        print("$item isn't deleted");
      });

      await firebase_storage.FirebaseStorage.instance
          .ref("/${widget.imageId}/${widget.imageId}_$item.wav")
          .delete()
          .then((value) {})
          .catchError((e) {
        print("errrr");
      });
    });

    selectedItems.clear();

    await _loadDta();
  }

  downloadItems() async {
    setState(() {
      isUploading = true;
    });

    Iterable inReverse = selectedItems.reversed;
    await Future.forEach(inReverse, (item) async {
      Directory d = Directory("/storage/emulated/0/Download/luttas/1");

      if (!d.existsSync()) {
        d.createSync(recursive: true);
      }

      await firebase_storage.FirebaseStorage.instance
          .ref("/1/1_12.wav")
          .writeToFile(File("${d.path}/1_12.wav"));
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
        .orderBy("UserId")
        .get()
        .then((value) {
      _audios.clear();
      value.docs.forEach((element) {
        if (element.data()["ImageId"] == widget.imageId) {
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

  bool idDownLoading = false;

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
      _audioPlayer.onPlayerStateChanged.listen((event) {
        print("14ppp$event");
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
        floatingActionButton:
            selectedItems.isEmpty || isUploading ? null : _buildBottoms(),
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
      return const Center(
          child: Text(
        "There are no Audios for this image",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
      ));
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          )),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Select All",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            IconButton(
                onPressed: () {
                  if (_audios.length != selectedItems.length) {
                    _audios.forEach((element) {
                      if (selectedItems.contains(element["UserId"])) {
                        print("contains");
                      } else {
                        selectedItems.add(element["UserId"]);
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

  Widget _buildBottoms() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            _sure(true);
          },
          child: const Icon(Icons.delete),
        ),
        const SizedBox(
          height: 15,
        ),
        FloatingActionButton(
          onPressed: () async{

          },
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
                        if (selectedItems.contains(_audios[index]["UserId"])) {
                          setState(() {
                            selectedItems.remove(_audios[index]["UserId"]);
                          });
                        } else {
                          setState(() {
                            selectedItems.add(_audios[index]["UserId"]);
                          });
                        }
                      },
                      icon: selectedItems.contains(_audios[index]["UserId"])
                          ? const Icon(
                              Icons.check_box,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.check_box_outlined,
                            )),
                  title: Text(
                      "${_audios[index]["ImageId"]}_${_audios[index]["UserId"]}"),
                  leading: Image.asset(
                    "images/${widget.imageId}.jpg",
                  )),
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
                            child: const Center(
                                child: CircularProgressIndicator()),
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
                    downloadItems();
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
