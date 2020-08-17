# Fedora PKG Scripts

## `update`
A simple BASH script that updates flatpaks, snaps, and RPM packages using `flatpak`, `snap`, and `dnf`. 

```
Usage: update [-fsra]

-f : flatpaks
-s : snaps
-r : rpms
-a : all (default)
```

## `autoremove`
A simple BASH script that autoremoves unused flatpaks, disabled snaps, and orphaned RPM packages using `flatpak`, `snap`, and `dnf`. 

```
Usage: autoremove [-fsra]

-f : flatpaks
-s : snaps
-r : rpms
-a : all (default)
```

## Install
Requires root. Install in `/usr/local/sbin`.