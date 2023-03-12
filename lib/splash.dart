import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luttas_admin/Home.dart';



class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late Timer timer;

  @override
  void initState() {


    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
            (route) => false,
      );
      timer.cancel();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, double value, child) =>
                Transform.scale(
                    scale: value,
                    child: Opacity(
                        opacity: value,
                        child: Image.asset("images/splash.jpg"))),
          )),
    );
  }
}
