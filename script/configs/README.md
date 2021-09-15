This folder contains configuration files that are passed to commands in place
of plugin lists. They are primarily used by CI to opt specific packages out of
tests, but can also useful when running multi-plugin tests locally.

**Any entry added to a file in this directory should include a comment**.
Skipping tests or checks for plugins is usually not something we want to do,
so should the comment should either include an issue link to the issue tracking
removing it or—much more rarely—explaining why it is a permanent exclusion.
