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
ui_print " 📝本内核来自："
ui_print " ◾️@486 (qq428579)"
ui_print " ◾️酷安:水手服的精彩"

$ksu_supported || abort "  -> 非GKI设备，终止安装。"

ui_print " "

if [ -f "$home/zram.zip" ]; then
    MODULE_PATH="$home/zram.zip"
else
    MODULE_PATH=""
fi

if [ -n "$MODULE_PATH" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print " 🛠是否安装 ZRAM 模块？(开启更多的压缩算法，不懂跳过)"
    ui_print " ◾️音量上：跳过"
    ui_print " ◾️音量下：安装"
    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print " ◾️正在安装 ZRAM 模块..."
                /data/adb/ksud module install "$MODULE_PATH"
                ui_print " ✅安装完成!"
            else
                ui_print " ❌未找到 KSUD，跳过安装。"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print " ❕已跳过 ZRAM 模块安装。"
            ;;
        *)
            ui_print " ❕未知按键输入，已跳过 ZRAM 模块安装。"
            ;;
    esac
    ui_print " "
fi

if [ ! -f "$home/Image" ]; then
    ui_print " ❌ 错误：内核镜像文件 Image 未找到"
    abort "❌安装失败：没有内核镜像文件"
fi

if [ -f "$home/tools/patch_android" ]; then
    KPTOOL="$home/tools/patch_android"
    KERNEL_IMAGE="$home/Image"
    ui_print " 🛠是否进行 KPM 修补？"
    ui_print " ◾️音量上：跳过"
    ui_print " ◾️音量下：进行"
    ui_print " "
    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            ui_print "  🛠进行 KPM 修补操作..."
            ORIG_SIZE=$(stat -c%s "$KERNEL_IMAGE" 2>/dev/null || stat -f%z "$KERNEL_IMAGE")
            ORIG_MD5=$(md5sum "$KERNEL_IMAGE" | cut -d' ' -f1)
            ui_print "   ◾️修补前大小: $((ORIG_SIZE / 1024 / 1024))MB"
            ui_print "   ◾️修补前MD5: ${ORIG_MD5:0:16}"
            
            cp "$KPTOOL" "$home/patch_android"
            chmod 777 "$home/patch_android"
            
            ui_print "   ◾️正在修补中..."
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
                
                ui_print "   ◾️修补后大小: $((NEW_SIZE / 1024 / 1024))MB"
                ui_print "   ◾️修补后MD5: ${NEW_MD5:0:16}"
                
                if [ "$ORIG_MD5" = "$NEW_MD5" ]; then
                    ui_print " ⚠️ KPM 修补完成，但内核未发生变化"
                else
                    ui_print " ✅ KPM 修补成功！"
                fi
            else
                ui_print " ❌ KPM 修补失败"
            fi
            
            rm -f "$home/patch_android"
            ;;
        "KEY_VOLUMEUP")
            ui_print " ❕已跳过 KPM 修补"
            ;;
        *)
            ui_print " ❕未知按键输入，已跳过"
            ;;
    esac
else
    ui_print " ❕未找到 KPM 修补工具，跳过"
fi

ui_print " "
ui_print " 📥正在刷入内核..."

if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
ui_print " ✅内核刷入完成！"
ui_print " "
ui_print " 🐧是否加入群组？"
ui_print " ◾️音量上：立即加入"
ui_print " ◾️音量下：已经加入"

key_click=""
while [ "$key_click" = "" ]; do
    key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done

case "$key_click" in
    "KEY_VOLUMEUP")
        ui_print " ◾️正在打开组织链接..."
        am start -a android.intent.action.VIEW -d "https://qun.qq.com/universal-share/share?ac=1&authKey=09GHYeotBX4cNL1o8w%2FF8j%2Bfx%2FcPIU0H5tMp5lO8ZXciwUxETL%2BEwe8gPbaldshS&busi_data=eyJncm91cENvZGUiOiIyODg0ODI5MTgiLCJ0b2tlbiI6InZSOUNTWWx1WVNJNWYrNlpUYWZEQkF4dmpQWVVwZFc1N1REVFFjYmpTR25MYldzTWxnK2NZRXhiVEZkbUtIUE8iLCJ1aW4iOiI0Mjg1NzkifQ%3D%3D&data=WwMC8aE8oVTgoGkPUiXAIs8nMVJZU4UkiWcX8qYMoFoNnTpIwVY7GCCZRX_1UO_Yi8udPzZuE_jESwmq4ABrwQ&svctype=4&tempid=h5_group_info" > /dev/null 2>&1
        ui_print " 💖感谢您的支持！" 
        ;;
    "KEY_VOLUMEDOWN")
        ui_print " 💖感谢您的支持！"
        ;;
    *)
        ui_print " 💖感谢您的支持！"
        ;;
esac
