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

ui_print " "
ui_print " 1.开始 KPM 内核修补..."

if [ -f "$home/tools/patch_android" ]; then
    KPTOOL="$home/tools/patch_android"
    ui_print "  找到 Android 专用修补工具"
elif [ -f "$home/tools/kptools" ]; then
    KPTOOL="$home/tools/kptools"
    ui_print "  找到通用修补工具"
else
    ui_print " ❌ 未找到 KPM 修补工具，跳过修补"
    KPTOOL=""
fi

if [ -n "$KPTOOL" ]; then
    
    chmod +x "$KPTOOL"
    
    if [ -f "$home/Image" ]; then
        KERNEL_IMAGE="$home/Image"
        ui_print "  找到内核镜像: Image"
    else
        ui_print " ❌ 未找到内核镜像文件 Image"
        KERNEL_IMAGE=""
    fi
    
    if [ -n "$KERNEL_IMAGE" ]; then
        ui_print "  正在应用 KPM 修补..."
        
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
    fi
fi

if [ -f "$AKHOME/ksu_module_susfs_1.5.2+_Release.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_Release.zip"
elif [ -f "$AKHOME/ksu_module_susfs_1.5.2+_CI.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+_CI.zip"
else
    MODULE_PATH=""
fi

if [ -n "$MODULE_PATH" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print " "
    ui_print " 2.是否安装 SUSFS 模块？"
    ui_print " 音量上：跳过安装"
    ui_print " 音量下：安装模块"

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print " 正在安装 SUSFS 模块..."
                /data/adb/ksud module install "$MODULE_PATH"
                ui_print " ✅安装完成!"
            else
                ui_print " ❌未找到 KSUD 跳过安装"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print " 已跳过 SUSFS 模块"
            ;;
        *)
            ui_print " 未知按键输入 已跳过 SUSFS 模块安装"
            ;;
    esac
fi

if [ -f "$AKHOME//ZRAM-Module_6.6_OnePlusAce5Pro_Android15.0.0.zip" ]; then
    MODULE_PATH_EXAMPLE="$AKHOME//ZRAM-Module_6.6_OnePlusAce5Pro_Android15.0.0.zip"
else
    MODULE_PATH_EXAMPLE=""
fi

if [ -n "$MODULE_PATH_EXAMPLE" ]; then
    KSUD_PATH="/data/adb/ksud"
    ui_print " "
    ui_print " 3.是否安装 Zram附加模块？"
    ui_print " 音量上：跳过安装"
    ui_print " 音量下：安装模块"

    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            if [ -f "$KSUD_PATH" ]; then
                ui_print " 正在安装 Zram附加模块..."
                /data/adb/ksud module install "$MODULE_PATH_EXAMPLE"
                ui_print " ✅安装完成!"
            else
                ui_print " ❌未找到 KSUD 跳过安装"
            fi
            ;;
        "KEY_VOLUMEUP")
            ui_print " 已跳过Zram附加模块安装"
            ;;
        *)
            ui_print " 未知按键输入 已跳过Zram附加模块模块安装"
            ;;
    esac
fi

ui_print " "
ui_print "⚠️所有操作完成！"