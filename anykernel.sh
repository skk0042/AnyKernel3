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
$ksu_supported || abort "  -> 非GKI设备，刷入截止"
ui_print " "
ui_print " 作者信息:"
ui_print " - 486 (QQ: 428579)"
ui_print " - 酷安:@水手服的精彩"
ui_print " - QQ组织:288482918"
ui_print " - TG频道:@SKK0042NB"
ui_print " "
ui_print " 是否修补KPM？音量上键跳过，音量下键修补"
sleep 0.1
key_click1=""
while [ "$key_click1" = "" ]; do
    key_click1=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done
case "$key_click1" in
    "KEY_VOLUMEDOWN")
        ui_print " - 开始修补..."
        PATCH_TOOL="tools/patch_android"
        if [ ! -f "$PATCH_TOOL" ]; then
            ui_print " × 错误：未找到KPM修补工具 -> $PATCH_TOOL"
            break
        fi
        chmod 777 "$PATCH_TOOL"
        "$PATCH_TOOL"
        if [ -f "oImage" ]; then
            rm -f Image
            mv oImage Image
            ui_print " √ 修补完成"
        else
            ui_print " × 修补失败"
        fi
        ;;
    "KEY_VOLUMEUP")
        ui_print " - 已跳过修补"
        ;;
    *)
        ui_print " ？未知按键，跳过修补"
        ;;
esac
ui_print " "
ui_print "- 开始刷入内核..."
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
ui_print " √ 内核刷入完成"
ui_print " "
ui_print " - 已跳转QQ群，进入组织或者频道获取最新资源或消息"
am start -a android.intent.action.VIEW -d "https://qun.qq.com/universal-share/share?ac=1&authKey=09GHYeotBX4cNL1o8w%2FF8j%2Bfx%2FcPIU0H5tMp5lO8ZXciwUxETL%2BEwe8gPbaldshS&busi_data=eyJncm91cENvZGUiOiIyODg0ODI5MTgiLCJ0b2tlbiI6InZSOUNTWWx1WVNJNWYrNlpUYWZEQkF4dmpQWVVwZFc1N1REVFFjYmpTR25MYldzTWxnK2NZRXhiVEZkbUtIUE8iLCJ1aW4iOiI0Mjg1NzkifQ%3D%3D&data=WwMC8aE8oVTgoGkPUiXAIs8nMVJZU4UkiWcX8qYMoFoNnTpIwVY7GCCZRX_1UO_Yi8udPzZuE_jESwmq4ABrwQ&svctype=4&tempid=h5_group_info"
