import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/quran_model.dart';
import '../models/quran_ayat_model.dart';

import '../widget/quran_read.dart';

class QuranDetail extends StatefulWidget {
  @override
  _QuranDetailState createState() => _QuranDetailState();
}

class _QuranDetailState extends State<QuranDetail> {
  int bottomIndex = 0;
  int offset = 0;
  int totalData = 0;
  int id;
  bool isPlay = false;
  bool isPaused = false;
  AudioPlayer audioPlayer = AudioPlayer();

  void play() async {
    if (!isPlay) {
      final mp3URL = Provider.of<QuranAyat>(context, listen: false).findMp3Url(id);
      int result =0;
      if(!isPaused)
        result = await audioPlayer.play(mp3URL);
      else
        result = await audioPlayer.resume();
      if (result == 1) {
        setState(() {
          isPlay = true;
        });
      }
    } else {
      int result = await audioPlayer.pause();
      if (result == 1) {
        setState(() {
          isPlay = false;
          isPaused = true;
        });
      }
    }
  }
  void stop() async {
    if(isPlay || isPaused){
      int result = await audioPlayer.stop();
      if (result == 1) {
        setState(() {
          isPlay = false;
          isPaused = false;
        });
      }
    }
  }

  void _changeBottomIndex(index) {
    if (index == 0) {
      play();
    }
    if (index == 1){
      stop();
    }

    setState(() {
      bottomIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    id = ModalRoute.of(context).settings.arguments as int;
    final data = Provider.of<QuranData>(context, listen: false).findById(id);

    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Al-Qur'an"),
              Text(
                '${data.name} - ${data.arab}',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(5),
          child: FutureBuilder(
            future:
            Provider.of<QuranAyat>(context, listen: false).getDetail(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error! Periksa Koneksi Anda"),
                  );
                } else {
                  return Consumer<QuranAyat>(
                    builder: (ctx, data, _) => ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.items.length,
                      itemBuilder: (ctx, i) => QuranRead(
                        data.items[i].ayatNumber,
                        data.items[i].ayatArab,
                        data.items[i].ayatText,
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: bottomIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(isPlay ? Icons.pause:Icons.play_arrow), title: Text('${!isPlay ? "Play":"Pause"}')),
            BottomNavigationBarItem(
                icon: Icon(Icons.stop), title: Text('Stop')),
          ],
          onTap: _changeBottomIndex,
        ));
  }
}