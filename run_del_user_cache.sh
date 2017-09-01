#!/bin/bash

mount -t cifs "//E4008S01SV001.indigo.schools.internal/fsSchools\Student Profiles\E4008S01-Bunbury SHS" /mnt/StudentProfiles/ -o username=<username>,password=<password>,noexec
python3 ./del_cache_dir.py
