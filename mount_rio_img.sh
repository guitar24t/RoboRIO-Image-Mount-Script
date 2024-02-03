#!/bin/bash
### mount_rio_img.sh
### Mount a RoboRIOv2 image so that the contents can be edited on a computer
### Usage: mount_rio_img.sh <img_file>

if [ $# -lt 1 ]
then
    echo "Incorrect number of arguments specified"
    exit 1
fi

FDISK_IMG_TABLE=$(fdisk -lu "${1}" | grep .img | tail -n +2)

COUNTER=0
while IFS= read -r line ;
do
    fdisk_arr=(${line})
    sector_start=${fdisk_arr[1]}
    sectors=${fdisk_arr[3]}
    if [ -z "${sector_start}" ];
    then
        echo "Incorrect format in start sector input string"
        exit 1
    fi

    let COUNTER++

    img_offset=$((${sector_start}*512))
    img_size=$((${sectors}*512))
    MOUNT_POINT=/mnt/FRC_Image_${COUNTER}
    sudo mkdir -p "${MOUNT_POINT}"
    sudo mount -o loop,offset=${img_offset},sizelimit=${img_size} "${1}" "${MOUNT_POINT}"
done <<< "${FDISK_IMG_TABLE}"

echo "Images are mounted at /mnt/FRC_Image_xxx and are now editable"
echo "Leave this window open and edit as needed."
read -p "Press enter to continue and unmount the images..."

sudo umount /mnt/FRC_Image_*
sudo rm -Rf /mnt/FRC_Image_*

echo "Cleanup successful!"