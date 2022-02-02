// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_COMHEAPPTR_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_COMHEAPPTR_H_

#include <windows.h>

#include <cassert>

namespace camera_windows {
// Wrapper for COM object for automatic memory release support
// Destructor uses CoTaskMemFree to release memory allocations.
template <typename T>
class ComHeapPtr {
 public:
  ComHeapPtr() : p_obj_(nullptr) {}
  ComHeapPtr(T* p_obj) : p_obj_(p_obj) {}

  // Frees memory on destruction.
  ~ComHeapPtr() { Free(); }

  // Prevent copying / ownership transfer as not currently needed.
  ComHeapPtr(ComHeapPtr const&) = delete;
  ComHeapPtr& operator=(ComHeapPtr const&) = delete;

  // Returns the pointer to the memory.
  operator T*() { return p_obj_; }

  // Returns the pointer to the memory.
  T* operator->() {
    assert(p_obj_ != nullptr);
    return p_obj_;
  }

  // Returns the pointer to the memory.
  const T* operator->() const {
    assert(p_obj_ != nullptr);
    return p_obj_;
  }

  // Returns the pointer to the memory.
  T** operator&() {
    // Wrapped object must be nullptr to avoid memory leaks.
    // Object can be released with Reset(nullptr).
    assert(p_obj_ == nullptr);
    return &p_obj_;
  }

  // Frees the memory pointed to, and sets the pointer to nullptr.
  void Free() {
    if (p_obj_) {
      CoTaskMemFree(p_obj_);
    }
    p_obj_ = nullptr;
  }

 private:
  // Pointer to memory.
  T* p_obj_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_COMHEAPPTR_H_
