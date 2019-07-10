// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'package:flutter/material.dart';
import './tabs/asset_tab.dart';
import './tabs/list_tab.dart';
import './tabs/live_tab.dart';
import './tabs/remote_tab.dart';
import './video_provider.dart';

// video urls
const String _kAssetPath = 'assets/Butterfly-209.mp4';
const String _kRemoteUrl =
    'http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8';
const String _kLiveUrl =
    'https://videos3.earthcam.com/fecnetwork/16560.flv/playlist.m3u8';

void main() {
  runApp(
    MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Video player example'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: <Widget>[
                Tab(icon: Icon(Icons.cloud), text: "Remote"),
                Tab(icon: Icon(Icons.live_tv), text: "Live"),
                Tab(icon: Icon(Icons.insert_drive_file), text: "Asset"),
                Tab(icon: Icon(Icons.list), text: "List example"),
              ],
            ),
          ),
          body: TabBarView(
            children: const <Widget>[
              VideoControllerProvider.network(
                source: _kRemoteUrl,
                child: RemoteTab(),
              ),
              VideoControllerProvider.network(
                source: _kLiveUrl,
                child: LiveTab(),
              ),
              VideoControllerProvider.asset(
                source: _kAssetPath,
                child: AssetTab(),
              ),
              VideoControllerProvider.asset(
                source: _kAssetPath,
                child: ListTab(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
