// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_TEST_TEST_UTILS_H_
#define PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_TEST_TEST_UTILS_H_

#include <comdef.h>
#include <comip.h>
#include <shlobj.h>
#include <shobjidl.h>
#include <windows.h>

#include <memory>
#include <string>
#include <type_traits>
#include <variant>

#include "file_dialog_controller.h"

_COM_SMARTPTR_TYPEDEF(IShellItem, IID_IShellItem);
_COM_SMARTPTR_TYPEDEF(IShellItemArray, IID_IShellItemArray);

namespace file_selector_windows {
namespace test {

// Creates a temp file, managed as an IShellItem, which will be deleted when
// the instance goes out of scope.
//
// This creates a file on the filesystem since creating IShellItem instances for
// files that don't exist is non-trivial.
class ScopedTestShellItem {
 public:
  ScopedTestShellItem();
  ~ScopedTestShellItem();

  // Disallow copy and assign.
  ScopedTestShellItem(const ScopedTestShellItem&) = delete;
  ScopedTestShellItem& operator=(const ScopedTestShellItem&) = delete;

  // Returns the file's IShellItem reference.
  IShellItemPtr file() { return item_; }

  // Returns the file's path.
  const std::wstring& path() { return path_; }

 private:
  IShellItemPtr item_;
  std::wstring path_;
};

// Creates a temp file, managed as an ITEMIDLIST, which will be deleted when
// the instance goes out of scope.
//
// This creates a file on the filesystem since creating IShellItem instances for
// files that don't exist is non-trivial, and this is intended for use in
// creating IShellItemArray instances.
class ScopedTestFileIdList {
 public:
  ScopedTestFileIdList();
  ~ScopedTestFileIdList();

  // Disallow copy and assign.
  ScopedTestFileIdList(const ScopedTestFileIdList&) = delete;
  ScopedTestFileIdList& operator=(const ScopedTestFileIdList&) = delete;

  // Returns the file's ITEMIDLIST reference.
  PIDLIST_ABSOLUTE file() { return item_.get(); }

  // Returns the file's path.
  const std::wstring& path() { return path_; }

 private:
  // Smart pointer for managing ITEMIDLIST instances.
  struct ItemIdListDeleter {
    void operator()(LPITEMIDLIST item) {
      if (item) {
        ::ILFree(item);
      }
    }
  };
  using ItemIdListPtr = std::unique_ptr<std::remove_pointer_t<PIDLIST_ABSOLUTE>,
                                        ItemIdListDeleter>;

  ItemIdListPtr item_;
  std::wstring path_;
};

}  // namespace test
}  // namespace file_selector_windows

#endif  // PACKAGES_FILE_SELECTOR_FILE_SELECTOR_WINDOWS_WINDOWS_TEST_TEST_UTILS_H_
