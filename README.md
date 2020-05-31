# andump

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

For Android Data Forensic

The different data storage options available on Android:

- Internal file storage: Store app-private files on the device file system.
- External file storage: Store files on the shared external file system. This is usually for shared user files, such as photos.
- Shared preferences: Store private primitive data in key-value pairs.
- Databases: Store structured data in a private database.

For Library checking:

More here https://enderspub.kubertu.com/android-security-research-crypto-wallet-local-storage-attack

# Do-na-te
Just in case you love it!

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=CFLQ8SMJTDQGJ&currency_code=EUR&source=url)

# Plan

1. Dump data from Sandbox and external enclaves
2. Print all sensitive data along with its file location
3. Based on the rules file, this needs to be updated 

Internal:
1. /data/data

External:
1. /mnt/sdcard/Android/data is a softlink to /sdcard/


Shared Preferences
SQLite Databases
Realm Databases
Internal Storage
External Storage

# Version

[Versions](https://github.com/enderphan94/andump/releases)

# Installation

```
./install.sh
```

# Usage

```
-ls                   : List installed package
-p <packagename>      : Check if sensitive data stored in internal & external data
-l true -f <file.apk> : Check if insecure library is set
-h                    : Help

```
Example

For Data Forensic:  ```./andump.sh -p com.google.android```

For Unreliable libraries: ```./andump.sh -l true -d /home/appcode```

You want to find your plaint-text password in the entire application structure from out and in sandbox data, you just need to insert them in ```/src/rules.txt``` and run ```./andump.sh -p com.yourapp.android```


