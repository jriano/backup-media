# Scripts to Backup Media

This set of scripts are used to backup pictures, videos and audios from your phone to your pc. The folder locations for source and destination must be given in the file.


All scripts use the source and destination folders provided in the following file, make sure to configure that before running the scripts:

```text
dirs.json
```

## How to delete live photos (.MOV) and convert .HEIC to .JPG

Run the helper scripts to remove .MOV live pictures and to convert the iPhone pictures to .JPG before runing the main backup script. This will help you save storage. Run them in the order shown next:

```bash
./helper_1_delete_iphone_live_pictures.sh 
./helper_2_convert_heic_to_jpg_pictures.sh 
```

## Backup up

After the above cleanup, run the main script:

```bash
./backup_media.sh
```

## Additional help

### To import pictures from iPhone

In ubuntu, `ifuse` is an awesome library that allows you to mount the iPhone storage as a regular storage folder, you can then use any file manager to extract the files into your pc. 

To delete the files from your iPhone use your phone's tools, using the pc for that does not give good results.

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
