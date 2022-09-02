// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/file_selector_linux/file_selector_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtest/gtest.h>
#include <gtk/gtk.h>

#include "file_selector_plugin_private.h"

// TODO(stuartmorgan): Restructure the helper to take a callback for showing
// the dialog, so that the tests can mock out that callback with something
// that changes the selection so that the return value path can be tested
// as well.
// TODO(stuartmorgan): Add an injectable wrapper around
// gtk_file_chooser_native_new to allow for testing values that are given as
// construction paramaters and can't be queried later.

TEST(FileSelectorPlugin, TestOpenSimple) {
  g_autoptr(FlValue) args = fl_value_new_map();

  g_autoptr(GtkFileChooserNative) dialog =
      create_dialog_for_method(nullptr, "openFile", args);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_OPEN);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
}

TEST(FileSelectorPlugin, TestOpenMultiple) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "multiple", fl_value_new_bool(true));

  g_autoptr(GtkFileChooserNative) dialog =
      create_dialog_for_method(nullptr, "openFile", args);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_OPEN);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            true);
}

TEST(FileSelectorPlugin, TestOpenWithFilter) {
  g_autoptr(FlValue) type_groups = fl_value_new_list();

  {
    g_autoptr(FlValue) text_group_mime_types = fl_value_new_list();
    fl_value_append_take(text_group_mime_types,
                         fl_value_new_string("text/plain"));
    g_autoptr(FlValue) text_group = fl_value_new_map();
    fl_value_set_string_take(text_group, "label", fl_value_new_string("Text"));
    fl_value_set_string(text_group, "mimeTypes", text_group_mime_types);
    fl_value_append(type_groups, text_group);
  }

  {
    g_autoptr(FlValue) image_group_extensions = fl_value_new_list();
    fl_value_append_take(image_group_extensions, fl_value_new_string("*.png"));
    fl_value_append_take(image_group_extensions, fl_value_new_string("*.gif"));
    fl_value_append_take(image_group_extensions,
                         fl_value_new_string("*.jgpeg"));
    g_autoptr(FlValue) image_group = fl_value_new_map();
    fl_value_set_string_take(image_group, "label",
                             fl_value_new_string("Images"));
    fl_value_set_string(image_group, "extensions", image_group_extensions);
    fl_value_append(type_groups, image_group);
  }

  {
    g_autoptr(FlValue) any_group_extensions = fl_value_new_list();
    fl_value_append_take(any_group_extensions, fl_value_new_string("*"));
    g_autoptr(FlValue) any_group = fl_value_new_map();
    fl_value_set_string_take(any_group, "label", fl_value_new_string("Any"));
    fl_value_set_string(any_group, "extensions", any_group_extensions);
    fl_value_append(type_groups, any_group);
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string(args, "acceptedTypeGroups", type_groups);

  g_autoptr(GtkFileChooserNative) dialog =
      create_dialog_for_method(nullptr, "openFile", args);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_OPEN);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
  // Validate filters.
  g_autoptr(GSList) type_group_list =
      gtk_file_chooser_list_filters(GTK_FILE_CHOOSER(dialog));
  EXPECT_EQ(g_slist_length(type_group_list), 3);
  GtkFileFilter* text_filter =
      GTK_FILE_FILTER(g_slist_nth_data(type_group_list, 0));
  GtkFileFilter* image_filter =
      GTK_FILE_FILTER(g_slist_nth_data(type_group_list, 1));
  GtkFileFilter* any_filter =
      GTK_FILE_FILTER(g_slist_nth_data(type_group_list, 2));
  // Filters can't be inspected, so query them to see that they match expected
  // filter behavior.
  GtkFileFilterInfo text_file_info = {};
  text_file_info.contains = static_cast<GtkFileFilterFlags>(
      GTK_FILE_FILTER_DISPLAY_NAME | GTK_FILE_FILTER_MIME_TYPE);
  text_file_info.display_name = "foo.txt";
  text_file_info.mime_type = "text/plain";
  GtkFileFilterInfo image_file_info = {};
  image_file_info.contains = static_cast<GtkFileFilterFlags>(
      GTK_FILE_FILTER_DISPLAY_NAME | GTK_FILE_FILTER_MIME_TYPE);
  image_file_info.display_name = "foo.png";
  image_file_info.mime_type = "image/png";
  EXPECT_TRUE(gtk_file_filter_filter(text_filter, &text_file_info));
  EXPECT_FALSE(gtk_file_filter_filter(text_filter, &image_file_info));
  EXPECT_FALSE(gtk_file_filter_filter(image_filter, &text_file_info));
  EXPECT_TRUE(gtk_file_filter_filter(image_filter, &image_file_info));
  EXPECT_TRUE(gtk_file_filter_filter(any_filter, &image_file_info));
  EXPECT_TRUE(gtk_file_filter_filter(any_filter, &text_file_info));
}

TEST(FileSelectorPlugin, TestSaveSimple) {
  g_autoptr(FlValue) args = fl_value_new_map();

  g_autoptr(GtkFileChooserNative) dialog =
      create_dialog_for_method(nullptr, "getSavePath", args);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_SAVE);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
}

TEST(FileSelectorPlugin, TestSaveWithArguments) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "initialDirectory",
                           fl_value_new_string("/tmp"));
  fl_value_set_string_take(args, "suggestedName",
                           fl_value_new_string("foo.txt"));

  g_autoptr(GtkFileChooserNative) dialog =
      create_dialog_for_method(nullptr, "getSavePath", args);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_SAVE);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
  g_autofree gchar* current_name =
      gtk_file_chooser_get_current_name(GTK_FILE_CHOOSER(dialog));
  EXPECT_STREQ(current_name, "foo.txt");
  // TODO(stuartmorgan): gtk_file_chooser_get_current_folder doesn't seem to
  // return a value set by gtk_file_chooser_set_current_folder, or at least
  // doesn't in a test context, so that's not currently validated.
}

TEST(FileSelectorPlugin, TestGetDirectory) {
  g_autoptr(FlValue) args = fl_value_new_map();

  g_autoptr(GtkFileChooserNative) dialog =
      create_dialog_for_method(nullptr, "getDirectoryPath", args);

  ASSERT_NE(dialog, nullptr);
  EXPECT_EQ(gtk_file_chooser_get_action(GTK_FILE_CHOOSER(dialog)),
            GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER);
  EXPECT_EQ(gtk_file_chooser_get_select_multiple(GTK_FILE_CHOOSER(dialog)),
            false);
}
