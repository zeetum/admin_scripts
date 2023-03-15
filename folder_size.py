import os

def folder_size(source):
        total_size = os.path.getsize(source)
        for item in os.listdir(source):
            itempath = os.path.join(source, item)
            if os.path.isfile(itempath):
                total_size += os.path.getsize(itempath)
            elif os.path.isdir(itempath):
                total_size += folder_size(itempath)
        return total_size

size = folder_size("/home/tum/") / (1024*1024*1024)

print(size, 'GB')
