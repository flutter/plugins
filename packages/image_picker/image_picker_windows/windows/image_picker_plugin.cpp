// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/image_picker_windows/image_picker_plugin.h"

#include <atlbase.h>
#include <atlstr.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <shobjidl.h>
#include <wincodec.h>
#include <windows.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>

namespace {

class ImagePickerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrar* registrar);

  ImagePickerPlugin();

  virtual ~ImagePickerPlugin();

 private:
  const std::string METHOD_CALL_IMAGE = "pickImage";
  const std::string METHOD_CALL_MULTI_IMAGE = "pickMultiImage";
  const std::string METHOD_CALL_VIDEO = "pickVideo";

  static std::string convertPWSTRToString(const wchar_t* pwsz);

  void ShowOpenFileDialog(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
      bool multiSelect, bool video);

  bool ImagePickerPlugin::TryGetDisplayName(IShellItem* pItem,
                                            flutter::EncodableValue& ret);

  HRESULT GetWICFileOpenDialogFilterSpecs(COMDLG_FILTERSPEC*& fileTypes,
                                          UINT& fileTypesCount);

  HRESULT GetVideoFileOpenDialogFilterSpecs(COMDLG_FILTERSPEC*& fileTypes,
                                            UINT& fileTypesCount);

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void ImagePickerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrar* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "plugins.flutter.io/image_picker",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ImagePickerPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

ImagePickerPlugin::ImagePickerPlugin() {}

ImagePickerPlugin::~ImagePickerPlugin() {}

void ImagePickerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare(METHOD_CALL_IMAGE) == 0) {
    ShowOpenFileDialog(std::move(result), false, false);
  } else if (method_call.method_name().compare(METHOD_CALL_MULTI_IMAGE) == 0) {
    ShowOpenFileDialog(std::move(result), true, false);
  } else if (method_call.method_name().compare(METHOD_CALL_VIDEO) == 0) {
    ShowOpenFileDialog(std::move(result), false, true);
  } else {
    result->NotImplemented();
  }
}

void ImagePickerPlugin::ShowOpenFileDialog(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,
    bool multiSelect, bool video) {
  auto hr =
      CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);
  if (SUCCEEDED(hr)) {
    IFileOpenDialog* pFileOpen;
    hr = CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL,
                          IID_IFileOpenDialog,
                          reinterpret_cast<void**>(&pFileOpen));

    if (SUCCEEDED(hr)) {
      if (multiSelect) {
        DWORD dwFlags;

        hr = pFileOpen->GetOptions(&dwFlags);
        if (SUCCEEDED(hr)) {
          hr = pFileOpen->SetOptions(dwFlags | FOS_ALLOWMULTISELECT);
        }
      }

      COMDLG_FILTERSPEC* fileTypes = NULL;
      UINT fileTypesCount = 0;

      if (video) {
        GetVideoFileOpenDialogFilterSpecs(fileTypes, fileTypesCount);
      } else {
        GetWICFileOpenDialogFilterSpecs(fileTypes, fileTypesCount);
      }

      pFileOpen->SetFileTypes(fileTypesCount, fileTypes);
      pFileOpen->SetFileTypeIndex(fileTypesCount);

      if (SUCCEEDED(hr)) {
        hr = pFileOpen->Show(NULL);
        if (SUCCEEDED(hr)) {
          IShellItem* pItem;
          if (multiSelect) {
            flutter::EncodableList returnValues;

            IShellItemArray* pRets;
            hr = pFileOpen->GetResults(&pRets);
            if (SUCCEEDED(hr)) {
              DWORD count;
              pRets->GetCount(&count);
              for (DWORD i = 0; i < count; i++) {
                pRets->GetItemAt(i, &pItem);

                if (SUCCEEDED(hr)) {
                  flutter::EncodableValue fileName;
                  if (ImagePickerPlugin::TryGetDisplayName(pItem, fileName)) {
                    returnValues.push_back(fileName);
                  }
                }
              }
              pRets->Release();
            }

            result->Success(returnValues);
          } else {
            hr = pFileOpen->GetResult(&pItem);

            if (SUCCEEDED(hr)) {
              flutter::EncodableValue fileName;
              if (ImagePickerPlugin::TryGetDisplayName(pItem, fileName)) {
                result->Success(fileName);
              } else {
                result->Success();
              }
            }
          }
        } else if (hr == HRESULT_FROM_WIN32(ERROR_CANCELLED)) {
          result->Success();
        }
      }

      for (UINT i = 0; i < fileTypesCount; i++) {
        delete[] fileTypes[i].pszName;
        delete[] fileTypes[i].pszSpec;
      }
      delete[] fileTypes;

      pFileOpen->Release();
    }
    CoUninitialize();
  }
}

bool ImagePickerPlugin::TryGetDisplayName(IShellItem* pItem,
                                          flutter::EncodableValue& ret) {
  LPWSTR pszFilePath;
  auto hr = pItem->GetDisplayName(SIGDN_FILESYSPATH, &pszFilePath);
  if (SUCCEEDED(hr)) {
    ret = flutter::EncodableValue(
        ImagePickerPlugin::convertPWSTRToString(pszFilePath));
    CoTaskMemFree(pszFilePath);
    pItem->Release();
    return true;
  } else {
    pItem->Release();
    return false;
  }
}

std::string ImagePickerPlugin::convertPWSTRToString(const wchar_t* pwsz) {
  char buf[0x400];
  char* pbuf = buf;
  size_t len = wcslen(pwsz) * 2 + 1;

  if (len >= sizeof(buf)) {
    pbuf = "error";
  } else {
    size_t converted;
    wcstombs_s(&converted, buf, pwsz, _TRUNCATE);
  }

  return std::string(pbuf);
}

HRESULT ImagePickerPlugin::GetWICFileOpenDialogFilterSpecs(
    COMDLG_FILTERSPEC*& fileTypes, UINT& fileTypesCount) {
  fileTypesCount = 1;  // Plus one for last option (all)
  CStringW strAllSpecs;

  // create IWICImagingFactory instance
  CComPtr<IWICImagingFactory> pIWICImagingFactory;
  HRESULT hr = pIWICImagingFactory.CoCreateInstance(CLSID_WICImagingFactory);

  // create WIC decoders enumerator
  CComPtr<IEnumUnknown> pIEnum;
  if (SUCCEEDED(hr)) {
    DWORD dwOptions = WICComponentEnumerateDefault;
    hr = pIWICImagingFactory->CreateComponentEnumerator(WICDecoder, dwOptions,
                                                        &pIEnum);
  }

  if (SUCCEEDED(hr)) {
    CComPtr<IUnknown> pElement;
    ULONG cbActual = 0;
    // count enumerator elements
    while (S_OK == pIEnum->Next(1, &pElement, &cbActual)) {
      ++fileTypesCount;
      pElement = NULL;
    }

    // alloc COMDLG_FILTERSPEC array
    fileTypes = new COMDLG_FILTERSPEC[fileTypesCount];

    // reset enumaration an loop again to fill filter specs array
    pIEnum->Reset();
    COMDLG_FILTERSPEC* pFilterSpec = fileTypes;
    while (S_OK == pIEnum->Next(1, &pElement, &cbActual)) {
      CComQIPtr<IWICBitmapDecoderInfo> pIWICBitmapDecoderInfo = pElement;
      // get necessary buffer size for friendly name and extensions
      UINT cbName = 0, cbFileExt = 0;
      pIWICBitmapDecoderInfo->GetFriendlyName(0, NULL, &cbName);
      pIWICBitmapDecoderInfo->GetFileExtensions(0, NULL, &cbFileExt);

      // get decoder friendly name
      (*pFilterSpec).pszName = new WCHAR[cbName];
      pIWICBitmapDecoderInfo->GetFriendlyName(
          cbName, (WCHAR*)(*pFilterSpec).pszName, &cbName);

      // get extensions; wee need to replace some characters according to the
      // specs
      CStringW strSpec;
      pIWICBitmapDecoderInfo->GetFileExtensions(
          cbFileExt, CStrBuf(strSpec, cbFileExt), &cbFileExt);
      strSpec.Replace(L',', L';');
      strSpec.Replace(L".", L"*.");
      size_t size = strSpec.GetLength() + 1;
      (*pFilterSpec).pszSpec = new WCHAR[size];
      wcscpy_s((wchar_t*)(*pFilterSpec).pszSpec, size, strSpec.GetString());

      // append to "All Image files" specs
      strSpec += L";";
      strAllSpecs += strSpec;

      ++pFilterSpec;
      pElement = NULL;
    }

    // set "All Image files" specs
    strAllSpecs.TrimRight(_T(';'));
    (*pFilterSpec).pszName = new WCHAR[wcslen(L"All Image files") + 1];
    wcscpy_s((wchar_t*)(*pFilterSpec).pszName, wcslen(L"All Image files") + 1,
             L"All Image files");
    (*pFilterSpec).pszSpec = new WCHAR[strAllSpecs.GetLength() + 1];
    wcscpy_s((wchar_t*)(*pFilterSpec).pszSpec, strAllSpecs.GetLength() + 1,
             strAllSpecs.GetString());
  }
  return S_OK;
}

HRESULT ImagePickerPlugin::GetVideoFileOpenDialogFilterSpecs(
    COMDLG_FILTERSPEC*& fileTypes, UINT& fileTypesCount) {
  fileTypesCount = 1;  // Plus one for last option (all)
  CStringW strAllSpecs;

  fileTypesCount += 4;

  fileTypes = new COMDLG_FILTERSPEC[fileTypesCount];

  COMDLG_FILTERSPEC* pFilterSpec = fileTypes;

  CStringW strName{L"Mov files"};
  size_t size = strName.GetLength() + 1;
  (*pFilterSpec).pszName = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszName, size, strName.GetString());
  CStringW strSpec{L"*.mov"};
  size = strSpec.GetLength() + 1;
  (*pFilterSpec).pszSpec = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszSpec, size, strSpec.GetString());
  strSpec += L";";
  strAllSpecs += strSpec;
  ++pFilterSpec;

  strName = L"WMV files";
  size = strName.GetLength() + 1;
  (*pFilterSpec).pszName = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszName, size, strName.GetString());
  strSpec = L"*.wmv";
  size = strSpec.GetLength() + 1;
  (*pFilterSpec).pszSpec = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszSpec, size, strSpec.GetString());
  strSpec += L";";
  strAllSpecs += strSpec;
  ++pFilterSpec;

  strName = L"MKV files";
  size = strName.GetLength() + 1;
  (*pFilterSpec).pszName = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszName, size, strName.GetString());
  strSpec = L"*.mkv";
  size = strSpec.GetLength() + 1;
  (*pFilterSpec).pszSpec = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszSpec, size, strSpec.GetString());
  strSpec += L";";
  strAllSpecs += strSpec;
  ++pFilterSpec;

  strName = L"MP4 files";
  size = strName.GetLength() + 1;
  (*pFilterSpec).pszName = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszName, size, strName.GetString());
  strSpec = L"*.mp4";
  size = strSpec.GetLength() + 1;
  (*pFilterSpec).pszSpec = new WCHAR[size];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszSpec, size, strSpec.GetString());
  strSpec += L";";
  strAllSpecs += strSpec;
  ++pFilterSpec;

  // set "All Video files" specs
  strAllSpecs.TrimRight(_T(';'));
  (*pFilterSpec).pszName = new WCHAR[wcslen(L"All Video files") + 1];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszName, wcslen(L"All Video files") + 1,
           L"All Video files");
  (*pFilterSpec).pszSpec = new WCHAR[strAllSpecs.GetLength() + 1];
  wcscpy_s((wchar_t*)(*pFilterSpec).pszSpec, strAllSpecs.GetLength() + 1,
           strAllSpecs.GetString());

  return S_OK;
}

}  // namespace

void ImagePickerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ImagePickerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrar>(registrar));
}