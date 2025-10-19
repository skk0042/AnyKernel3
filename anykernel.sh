### AnyKernel3 Ramdisk Mod Script
## KernelSU with SUSFS By Skk0042
## osm0sis @ xda-developers
### AnyKernel setup
# global properties
properties() { '
kernel.string=OnePlus Kernel by skk0042
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
ui_print " 📝本内核来自：@skk0042 (qq428579）"
ui_print " "

$ksu_supported || abort "  -> Non-GKI device, abort."

ui_print " ⚠️开始安装内核..."
ui_print " "

if [ -f "$home/tools/patch_android" ]; then
    KPTOOL="$home/tools/patch_android"
elif [ -f "$home/tools/kptools" ]; then
    KPTOOL="$home/tools/kptools"
else
    ui_print " ❌ 未找到 KPM 修补工具"
    KPTOOL=""
fi

if [ -n "$KPTOOL" ] && [ -f "$home/Image" ]; then
    KERNEL_IMAGE="$home/Image"
    ui_print " "
    ui_print " 🛠是否执行 KPM 内核修补？"
    ui_print "  - 音量上：跳过修补"
    ui_print "  - 音量下：执行修补"

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            ui_print "  正在进行 KPM 修补..."
            chmod +x "$KPTOOL"
            
            # 执行修补
            if [ "$(basename $KPTOOL)" = "patch_android" ]; then
                "$KPTOOL" "$KERNEL_IMAGE"
            else
                "$KPTOOL" patch --image "$KERNEL_IMAGE" --kpm
            fi
            
            if [ $? -eq 0 ]; then
                ui_print " ✅ KPM 修补成功"
            else
                ui_print " ❌ KPM 修补失败"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print " 已跳过 KPM 修补"
            ;;
        *)
            ui_print " 未知按键输入 已跳过 KPM 修补"
            ;;
    esac
else
    ui_print "  跳过 KPM 修补（缺少工具或内核镜像）"
fi

ui_print " "

SUSFS_MODULE_PATH=""
for file in "$home"/*.zip; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if echo "$filename" | grep -qi "susfs"; then
            SUSFS_MODULE_PATH="$file"
            ui_print "  找到 SUSFS 模块: $filename"
            break
        fi
    fi
done

if [ -z "$SUSFS_MODULE_PATH" ]; then
    for file in "$home"/modules/*.zip; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            if echo "$filename" | grep -qi "susfs"; then
                SUSFS_MODULE_PATH="$file"
                ui_print " 找到 SUSFS 模块: $filename"
                break
            fi
        fi
    done
fi

if [ -n "$SUSFS_MODULE_PATH" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print " "
    ui_print " 📡是否安装 SUSFS 模块？(不推荐)"
    ui_print "  - 音量上：跳过安装"
    ui_print "  - 音量下：安装模块"

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print " 正在安装 SUSFS 模块..."
                /data/adb/ksud module install "$SUSFS_MODULE_PATH"
                ui_print " ✅安装完成!"
            else
                ui_print " ❌未找到 KSUD 跳过安装"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print " 已跳过 SUSFS 模块安装"
            ;;
        *)
            ui_print " 未知按键输入 已跳过 SUSFS 模块安装"
            ;;
    esac
else
    ui_print "  跳过 SUSFS 模块安装（未找到模块文件）"
fi

ui_print " "

ZRAM_MODULE_PATH=""
for file in "$home"/*.zip; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if echo "$filename" | grep -qi "zram"; then
            ZRAM_MODULE_PATH="$file"
            ui_print "  找到 ZRAM 模块: $filename"
            break
        fi
    fi
done

if [ -z "$ZRAM_MODULE_PATH" ]; then
    for file in "$home"/modules/*.zip; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            if echo "$filename" | grep -qi "zram"; then
                ZRAM_MODULE_PATH="$file"
                ui_print " 找到 ZRAM 模块: $filename"
                break
            fi
        fi
    done
fi

if [ -n "$ZRAM_MODULE_PATH" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print " "
    ui_print " 🔧是否安装 ZRAM 模块（开启lz4压缩算法）?"
    ui_print "  - 音量上：跳过安装"
    ui_print "  - 音量下：安装模块"

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print " 正在安装 Zram 模块..."
                /data/adb/ksud module install "$ZRAM_MODULE_PATH"
                ui_print " ✅安装完成!"
            else
                ui_print " ❌未找到 KSUD 跳过安装"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print " 已跳过 Zram 模块安装"
            ;;
        *)
            ui_print " 未知按键输入 已跳过 Zram 模块安装"
            ;;
    esac
else
    ui_print " 跳过 ZRAM 模块安装（未找到模块文件）"
fi

ui_print " "
ui_print " "
ui_print " 🎉所有操作完成！"
ui_print " "
ui_print " 🐧进入组织吗？"
ui_print "  - 音量上：现在进去"
ui_print "  - 音量下：已经进了"

key_click=""
while [ "$key_click" = "" ]; do
    key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done

case "$key_click" in
    "KEY_VOLUMEUP")
        am start -a android.intent.action.VIEW -d "https://qun.qq.com/universal-share/share?ac=1&authKey=09GHYeotBX4cNL1o8w%2FF8j%2Bfx%2FcPIU0H5tMp5lO8ZXciwUxETL%2BEwe8gPbaldshS&busi_data=eyJncm91cENvZGUiOiIyODg0ODI5MTgiLCJ0b2tlbiI6InZSOUNTWWx1WVNJNWYrNlpUYWZEQkF4dmpQWVVwZFc1N1REVFFjYmpTR25MYldzTWxnK2NZRXhiVEZkbUtIUE8iLCJ1aW4iOiI0Mjg1NzkifQ%3D%3D&data=WwMC8aE8oVTgoGkPUiXAIs8nMVJZU4UkiWcX8qYMoFoNnTpIwVY7GCCZRX_1UO_Yi8udPzZuE_jESwmq4ABrwQ&svctype=4&tempid=h5_group_info" > /dev/null 2>&1
        ui_print " ✅已尝试打开"
        ;;
    "KEY_VOLUMEDOWN")
        ui_print " 💖感谢您的支持！"
        ;;
    *)
        ui_print " 💖感谢您的支持！"
        ;;
esac

ui_print " "
ui_print "✨刷写完成 请重启你的设备！"