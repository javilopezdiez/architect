sudo chattr -i /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82
sudo sh -c 'printf "\x07\x00\x00\x00\x00" > /sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82'
