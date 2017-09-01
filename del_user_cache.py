#!/usr/bin/python

import os
import shutil

# Deletes the cache_directory for all users in the user_dir
# user_dir = users directory
# cache_dir = relative path of the cache directory to delete
# e.g. del_cache_dir("\\network_path\users", "subfolder\to\cache")
def del_cache_dir(user_dir, cache_dir):

    users = os.listdir(user_dir)
    for user in users:

        full_path = user_dir + "/" + user + "/" + cache_dir
        if os.path.isdir(full_path):
            print("Deleting: " + full_path)
            shutil.rmtree(full_path,ignore_errors=True)

del_cache_dir("/mnt/StudentProfiles", "Application Data/Mozilla")
del_cache_dir("/mnt/StudentProfiles", "Roaming Profile.V2/AppData/Local/Google")
del_cache_dir("/mnt/StudentProfiles", "Roaming Profile.V2/AppData/Local/Microsoft/Internet Explorer")
del_cache_dir("/mnt/StudentProfiles", "Roaming Profile.V2/AppData/Local/Microsoft/Windows/INetCache")
del_cache_dir("/mnt/StudentProfiles", "Roaming Profile.V2/AppData/Local/Microsoft/Windows/Temporary Internet Files")
