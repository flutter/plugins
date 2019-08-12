// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config;

/// LastFetchStatus defines the possible status values of the last fetch.
enum LastFetchStatus { success, failure, throttled, noFetchYet }
