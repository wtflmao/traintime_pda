/*
Intro of the sport data.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/
import 'package:flutter/material.dart';
import 'package:watermeter/ui/tool/sport/subwindow/punchRecord.dart';
import 'package:watermeter/ui/tool/sport/subwindow/sportScore.dart';

class SportWindow extends StatelessWidget {
  const SportWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabForSport();
  }
}

class TabForSport extends StatelessWidget {
  const TabForSport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("体育查询"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('关于体育查询'),
                      content: const Text(
                        "Copyright 2022 SuperBart. \nMPL 2.0 License.",
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("确定"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit)),
              Tab(icon: Icon(Icons.run_circle)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PunchRecordWindow(),
            SportScoreWindow(),
          ],
        ),
      ),
    );
  }
}