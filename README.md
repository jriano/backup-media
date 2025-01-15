# Backup Media

This set of scripts are used to backup pictures, videos and audios from your phone to your pc. The folder locations for source and destination must be given in the file

```text
dirs.json
```

All scripts use the file locations given there.


### Delete live photos (.MOV) and convert .HEIC to .JPG

Run the helper scripts to remove .MOV live pictures and to convert the iPhone pictures to .JPG before runing the main backup script. This will help you save storage. Run them in the order shown next:

```bash
./helper_1_delete_iphone_live_pictures.sh 
./helper_2_convert_heic_to_jpg_pictures.sh 
```

## Backup up

```bash
./backup_media.sh
```

## Additional help

### To import pics from iPhone

```bash
## Use ifuse to load the iphone media
mkdir ~/iphone
ifuse ~/iphone
# Once done unmount
fusermount -u ~/iphone
```


## To do

- Remove directories if they are empty
- create log by run
- open picture in viewer and mark it as special
- make all a single file/script
- implement prime photos
- implement prime videos
