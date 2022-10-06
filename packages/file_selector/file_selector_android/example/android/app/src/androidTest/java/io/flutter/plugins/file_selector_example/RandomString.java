// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector_example;

import java.util.Random;

public class RandomString {
  private static final Random m_random = new Random();
  private static final char[] m_letters = new char['z' - 'a'];

  static {
    for (int i = 0; i < m_letters.length; i++) {
      m_letters[i] = (char) ('a' + i);
    }
  }

  static String generate(int length) {
    StringBuilder stringBuilder = new StringBuilder(length);
    for (int i = 0; i < length; i++) {
      int randomLetterId = m_random.nextInt(m_letters.length);
      char randomLetter = m_letters[randomLetterId];
      stringBuilder.append(randomLetter);
    }
    return stringBuilder.toString();
  }
}
