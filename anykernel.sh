### AnyKernel3 Ramdisk Mod Script
### AnyKernel setup
# global properties
properties() { '
kernel.string=OnePlus Kernel build by @486
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties
### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1
# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh
kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    4.1*) ksu_supported=true ;;
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac
ui_print " "
ui_print " This kernel is from:"
ui_print " - @486 (QQ: 428579)"
ui_print " - Coolapk: @水手服的精彩"
$ksu_supported || abort "  -> Non-GKI device, installation aborted."
ui_print " "
if [ ! -f "$home/Image" ]; then
    ui_print " × Error: Kernel image file 'Image' not found"
    abort "× Installation failed: No kernel image file"
fi
if [ -f "$home/tools/patch_android" ]; then
    KPTOOL="$home/tools/patch_android"
    KERNEL_IMAGE="$home/Image"
    ui_print " Tools: Perform KPM patching?"
    ui_print " - Volume Up: Skip"
    ui_print " - Volume Down: Proceed"
    ui_print " "
    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done
    case "$key_click" in
        "KEY_VOLUMEDOWN")
            ui_print " Tools: Performing KPM patching..."
            ORIG_SIZE=$(stat -c%s "$KERNEL_IMAGE" 2>/dev/null || stat -f%z "$KERNEL_IMAGE")
            ORIG_MD5=$(md5sum "$KERNEL_IMAGE" | cut -d' ' -f1)
            ui_print "  - Size before patching: $((ORIG_SIZE / 1024 / 1024))MB"
            ui_print "  - MD5 before patching: ${ORIG_MD5:0:16}"
            
            cp "$KPTOOL" "$home/patch_android"
            chmod 777 "$home/patch_android"
            
            ui_print "  - Patching in progress..."
            cd "$home"
            ./patch_android
            PATCH_RESULT=$?
            cd - > /dev/null
            
            if [ -f "$home/oImage" ]; then
                OIMAGE_SIZE=$(stat -c%s "$home/oImage" 2>/dev/null || stat -f%z "$home/oImage")
                
                rm -f "$home/Image"
                mv "$home/oImage" "$home/Image"
                
                NEW_SIZE=$(stat -c%s "$KERNEL_IMAGE" 2>/dev/null || stat -f%z "$KERNEL_IMAGE")
                NEW_MD5=$(md5sum "$KERNEL_IMAGE" | cut -d' ' -f1)
                
                ui_print "  - Size after patching: $((NEW_SIZE / 1024 / 1024))MB"
                ui_print "  - MD5 after patching: ${NEW_MD5:0:16}"
                
                if [ "$ORIG_MD5" = "$NEW_MD5" ]; then
                    ui_print " ! KPM patching completed, but kernel remains unchanged"
                else
                    ui_print " √ KPM patching successful!"
                fi
            else
                ui_print " × KPM patching failed"
            fi
            
            rm -f "$home/patch_android"
            ;;
        "KEY_VOLUMEUP")
            ui_print " Note: KPM patching skipped"
            ;;
        *)
            ui_print " Note: Unknown key input, skipped"
            ;;
    esac
else
    ui_print " Note: KPM patching tool not found, skipped"
fi
ui_print " "
ui_print " Flashing kernel now..."
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
ui_print " √ Kernel flashing completed!"
ui_print " "
ui_print " Join the QQ group?"
ui_print " - Volume Up: Join now"
ui_print " - Volume Down: Already joined"
key_click=""
while [ "$key_click" = "" ]; do
    key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done
case "$key_click" in
    "KEY_VOLUMEUP")
        ui_print " - Opening group link..."
        am start -a android.intent.action.VIEW -d "https://qun.qq.com/universal-share/share?ac=1&authKey=09GHYeotBX4cNL1o8w%2FF8j%2Bfx%2FcPIU0H5tMp5lO8ZXciwUxETL%2BEwe8gPbaldshS&busi_data=eyJncm91cENvZGUiOiIyODg0ODI5MTgiLCJ0b2tlbiI6InZSOUNTWWx1WVNJNWYrNlpUYWZEQkF4dmpQWVVwZFc1N1REVFFjYmpTR25MYldzTWxnK2NZRXhiVEZkbUtIUE8iLCJ1aW4iOiI0Mjg1NzkifQ%3D%3D&data=WwMC8aE8oVTgoGkPUiXAIs8nMVJZU4UkiWcX8qYMoFoNnTpIwVY7GCCZRX_1UO_Yi8udPzZuE_jESwmq4ABrwQ&svctype=4&tempid=h5_group_info" > /dev/null 2>&1
        ui_print " Thank you for your support!" 
        ;;
    "KEY_VOLUMEDOWN")
        ui_print " Thank you for your support!"
        ;;
    *)
        ui_print " Thank you for your support!"
        ;;
esac
