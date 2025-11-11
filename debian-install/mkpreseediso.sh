#!/bin/sh

set -e

ISO="$1"
NEW_ISO="$2"
WD="$(mktemp -d)"
OLD_PWD="$(pwd)"
echo $ISO
echo $WD
echo $OLD_PWD
7z x -o"$WD" "$ISO"

cd "$WD"

gunzip install.amd/initrd.gz
cp "$OLD_PWD/preseed.cfg" .
echo preseed.cfg | cpio -o -H newc -A -F install.amd/initrd
rm preseed.cfg
gzip install.amd/initrd

find -follow -type f -print0 | xargs --null md5sum >md5sum.txt

# Extract MBR template file to disk
dd if="$OLD_PWD/$ISO" bs=1 count=432 of="isohdpfx.bin"

xorriso -as mkisofs -o "$NEW_ISO" -isohybrid-mbr "isohdpfx.bin" \
  -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 \
  -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat "$WD"

cd "$OLD_PWD"

cp -f "$WD/$NEW_ISO" .

rm -r "$WD"
