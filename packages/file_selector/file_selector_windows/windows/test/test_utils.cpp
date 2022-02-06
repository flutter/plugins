// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "test/test_utils.h"

#include <shobjidl.h>
#include <windows.h>

#include <string>

namespace file_selector_windows {
namespace test {

namespace {

// Creates a temp file and returns its path.
std::wstring CreateTempFile() {
  wchar_t temp_dir[MAX_PATH];
  wchar_t temp_file[MAX_PATH];
  wchar_t long_path[MAX_PATH];
  ::GetTempPath(MAX_PATH, temp_dir);
  ::GetTempFileName(temp_dir, L"test", 0, temp_file);
  // Convert to long form to match what IShellItem queries will return.
  ::GetLongPathName(temp_file, long_path, MAX_PATH);
  return long_path;
}

}  // namespace

ScopedTestShellItem::ScopedTestShellItem() {
  path_ = CreateTempFile();
  ::SHCreateItemFromParsingName(path_.c_str(), nullptr, IID_PPV_ARGS(&item_));
}

ScopedTestShellItem::~ScopedTestShellItem() { ::DeleteFile(path_.c_str()); }

ScopedTestFileIdList::ScopedTestFileIdList() {
  path_ = CreateTempFile();
  item_ = ItemIdListPtr(::ILCreateFromPath(path_.c_str()));
}

ScopedTestFileIdList::~ScopedTestFileIdList() { ::DeleteFile(path_.c_str()); }

}  // namespace test
}  // namespace file_selector_windows
