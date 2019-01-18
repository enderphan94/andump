# andump
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

For Android Data Forensic

The different data storage options available on Android:

- Internal file storage: Store app-private files on the device file system.
- External file storage: Store files on the shared external file system. This is usually for shared user files, such as photos.
- Shared preferences: Store private primitive data in key-value pairs.
- Databases: Store structured data in a private database.
# Plan

1. Dump data from Sandbox and external enclaves
2. Print all sensitive data along with its file location
3. Based on the rules file, this needs to be updated 

Internal:
1. /data/data

External:
1. /mnt/sdcard/Android/data is a softlink to /sdcard/
2. /


Shared Preferences
SQLite Databases
Realm Databases
Internal Storage
External Storage
# Installation

```
./install.sh
```

# Usage

```

./andump.sh -p <packagename>

./andump.sh -l true -f <file.apk>

```
Example

For Data Forensic:  ```./andump.sh -p com.google.android```

For Unreliable libraries: ```./andump.sh -l true -d /home/appcode```

## For Unreliable Libraries

Read more here https://enderphan.e-cyber.ee/library/soft-link#object-persistence

