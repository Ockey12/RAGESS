# Setup for RAGESS developers

RAGESS is formatted by [SwiftFormat](https://github.com/nicklockwood/SwiftFormat).

The following configuration will allow SwiftFormat to run automatically when pushing to a remote repository.

If the file is modified by SwiftFormat, which is automatically executed when pushing, the push is blocked;
the developer checks the file for changes, commits, and pushes again.
If the file is not modified by SwiftFormat, the push is successful.

1. Clone this project.
2. Install [SwiftFormat](https://github.com/nicklockwood/SwiftFormat), if needed.
3. In the root directory of this project, execute `./setup-hooks.sh`.
