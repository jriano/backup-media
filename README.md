#backup-your-pictures

- Remove directories if they are empty
- Check if file already exist, and rename if they do but they are different
    - https://stackoverflow.com/questions/17286290/rsync-checksum-only-for-same-size-files
- create log by run


'/home/juan/Dropbox/Camera' is not readable or does not contain EXIF data!
Source:      /home/juan/Dropbox/Camera
Destination: /media/juan/T2/Familia-Riano-Fotos//no-date
rsync: link_stat "/home/juan/Dropbox/Camera" failed: No such file or directory (2)
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1196) [sender=3.1.2]
Failed to backup /home/juan/Dropbox/Camera
Aborting copying, please check folder permissions.
