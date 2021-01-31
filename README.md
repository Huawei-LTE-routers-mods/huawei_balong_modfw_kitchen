Huawei Balong ModFW Kitchen
===========================

This small script was made to aid in porting modifications of Huawei Balong modems and routers to any original firmware.  
Not all Balong devices have ready-to-use custom firmware files, as some routers are less common or more expensive than others. Many modifications are universal within selected Balong family and work on any family device.

This script is made to port such universal modifications to any device in automatic mode, and to make modification maintenance easier and cleaner.

### Modifications

Currently there's Balong V7R1, V7R2 and V7R11 family files present in this repository, for devices with and without OLED screen.

Features:

* ADB and Telnet access
* Support for IPv6 on mobile networks (disabled by default, could be activated "ipv6" script)
* The stock busybox, iptables and ip6tables binaries are replaced with full-fledged versions
* "atc" utility is installed to send AT commands from the console
* "ttl" script to modify (fix) TTL (for IPv4) and HL (for IPv6) of forwarded packets
* "imei" script to change IMEI
* A local transparent proxy server "tpws" and a script "anticensorship" to circumvent censorship to sites from the registry of prohibited sites in Russian Federation (IPv4 only)
* DNS over TLS resolver stubby (version 1.5.2, compiled with OpenSSL 1.0.2u) and DNS-level adblock (IPv4 only)
* Unlock of all NVRAM items
* AT^DATALOCK unlock patch
* Unsigned kernel module loading patch (for 21.333+ firmware versions)
* OpenVPN (version 2.5.0, compiled with OpenSSL 1.0.2u) and scripts for DNS redirection
* curl (version 7.74.0, compiled with OpenSSL 1.0.2u)
* Script for installing Entware application repository with [more than 2500 packages available](http://bin.entware.net/armv7sf-k3.2/Packages.html)
* "adblock_update" script for updating the list of advertising domains
* Removed mobile connection logging (mobile logger) to extend flash memory lifetime

### Folder structure

The kitchen has 2 main directories: **base** directory, where the family files are stored, and **device_overlay** directory, for device-specific scripts, configuration and binary files.

There are also pre-copy and post-copy scripts, which run before and after base and device_overlay files are copied, as well as output (building) scripts, which output final cpio image.

Consider the following: you want to build a firmware for E8372h-153 version 21.333.64.00.1456. You take the original firmware, unpack it, and run the script:

```
$ ./build.sh v7r11 e8372h orig_fw

    Original firmware
            ⇓
       base → v7r11
            ⇓
 device_overlay → e8372h
            ⇓
     Custom firmware
```

1. The **original firmware** is copied into working directory `workdir`
2. `base/v7r11/before_copy.sh` is executed
3. `base/v7r11/` files are copied into `workdir`
4. `base/v7r11/after_copy.sh` is executed
5. `device_overlay/e8372h/before_copy.sh` is executed
6. `device_overlay/e8372h/` files are copied
7. `device_overlay/e8372h/after_copy.sh` is executed
8. `device_overlay/e8372h/output.sh` is executed. If it's missing, `base/v7r11/output.sh` is run.

You'll get modified file system in `workdir/system` and cpio image in `workdir/system.cpio`.

### How to use

Add your device folder into `device_overlay` and execute the script.

```
build.sh <balong family from base folder> <device name from device_overlay> <original firmware directory>
Example: build.sh v7r11 e8372h-153_zong_21.333.64.00.1456 orig_fw
```
