# Backup Media

Script:
./backup_media

This script uses the file locations given in
dirs.json

to backup audio, video and images.

## To do

- Remove directories if they are empty
- create log by run
- open picture in viewer and mark it as special
- make all a single file/script
- implement prime photos
- implement prime videos


## Additional help

### To import pics from iPhone

```bash
## Use ifuse to load the iphone media
mkdir ~/iphone
ifuse ~/iphone
# Once done unmount
fusermount -u ~/iphone
```

### Delete live photos (.MOV) 

This script deletes .MOV files that have a matching SHEIC file.


