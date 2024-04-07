# Setup for RAGESS developers

RAGESS is formatted by [SwiftFormat](https://github.com/nicklockwood/SwiftFormat).

The following configuration will allow SwiftFormat to run automatically when pushing to a remote repository.

If the file is modified by SwiftFormat, which is automatically executed when pushing, the push is blocked;
the developer checks the file for changes, commits, and pushes again.
If the file is not modified by SwiftFormat, the push is successful.

1. Clone this project.
1. Install [SwiftFormat](https://github.com/nicklockwood/SwiftFormat), if needed. For example, execute the following command.
    ```
    brew install swiftformat
    ```
1. Go to the root directory of this project. For example, execute the following command.
    ```
    cd RAGESS
    ```
1. Execute the following command to grant execute permission to [setup-hooks.sh](https://github.com/Ockey12/RAGESS/blob/main/setup-hooks.sh).
    ```
    chmod +x setup-hooks.sh
    ```
1. To generate `.git/hooks/pre-push`, execute the following command.
    ```
    ./setup-hooks.sh
    ```
