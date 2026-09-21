#!/bin/bash
# https://gist.github.com/0xbb/ae298e2798e1c06d0753

# 11 inch
# disable
# sudo chattr -i /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82
# sudo sh -c 'printf "\x07\x00\x00\x00\x00" > /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82'

# 9,1 12
# disable
# sudo chattr -i /sys/firmware/efi/efivars/SystemAudioVolumeDB-7c436110-ab2a-4bbb-a880-fe41995c9f82
# sudo sh -c 'printf "\x07\x00\x00\x00\x80" > /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82'
# sudo sh -c 'printf "\x07\x00\x00\x00\x80" > /sys/firmware/efi/efivars/SystemAudioVolumeDB-7c436110-ab2a-4bbb-a880-fe41995c9f82'
# sudo chattr +i /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82
# sudo chattr +i /sys/firmware/efi/efivars/SystemAudioVolumeDB-7c436110-ab2a-4bbb-a880-fe41995c9f82
# enable
sudo rm /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82
sudo rm /sys/firmware/efi/efivars/SystemAudioVolumeDB-7c436110-ab2a-4bbb-a880-fe41995c9f82


