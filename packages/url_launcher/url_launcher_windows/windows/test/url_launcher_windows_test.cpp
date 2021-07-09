#include <gtest/gtest.h>

TEST(TestMe, HelloTestWorld) {
  EXPECT_STRNE("hello", "world");
  EXPECT_TRUE(false);
}
