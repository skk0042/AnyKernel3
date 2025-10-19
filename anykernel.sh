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
ui_print " 📝Anykernel3 From："
ui_print " ◾️Github@skk0042"
ui_print " ◾️CoolApk:水手服的精彩"
ui_print " "

$ksu_supported || abort "  -> Non-GKI device, abort."

ui_print " "


if [ ! -f "$home/Image" ]; then
    ui_print " ❌ エラー：カーネルイメージファイル Image が見つかりません"
    abort "インストール失敗：カーネルイメージがありません"
fi

if [ -f "$home/tools/patch_android" ]; then
    KPTOOL="$home/tools/patch_android"
    KERNEL_IMAGE="$home/Image"
    ui_print " 🛠KPM パッチを適用しますか？"
    ui_print " ◾️音量上：パッチをスキップ"
    ui_print " ◾️音量下：パッチを適用"
    ui_print " "
    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done

    case "$key_click" in
        "KEY_VOLUMEDOWN")
            ui_print "  🛠KPM パッチを適用中..."
            ORIG_SIZE=$(stat -c%s "$KERNEL_IMAGE" 2>/dev/null || stat -f%z "$KERNEL_IMAGE")
            ORIG_MD5=$(md5sum "$KERNEL_IMAGE" | cut -d' ' -f1)
            ui_print "   ◾️パッチ前サイズ: $((ORIG_SIZE / 1024 / 1024))MB"
            ui_print "   ◾️パッチ前MD5: ${ORIG_MD5:0:16}"
            
            cp "$KPTOOL" "$home/patch_android"
            chmod 777 "$home/patch_android"
            
            ui_print "   ◾️パッチ適用中..."
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
                
                ui_print "   ◾️パッチ後サイズ: $((NEW_SIZE / 1024 / 1024))MB"
                ui_print "   ◾️パッチ後MD5: ${NEW_MD5:0:16}"
                
                if [ "$ORIG_MD5" = "$NEW_MD5" ]; then
                    ui_print " ⚠️KPM パッチ完了、しかしカーネルは変更されませんでした"
                else
                    ui_print " ✅KPM パッチ成功"
                fi
            else
                ui_print " ❌KPM パッチ失敗"
            fi
            
            rm -f "$home/patch_android"
            ;;
        "KEY_VOLUMEUP")
            ui_print " ❕KPM パッチをスキップしました"
            ;;
        *)
            ui_print " ❕不明なキー入力、KPM パッチをスキップしました"
            ;;
    esac
else
    ui_print " ❕KPM パッチツールが見つかりません、パッチをスキップします"
fi

ui_print " "
ui_print " 🖇️カーネルイメージを検証中..."

if [ -f "$home/Image" ]; then
    IMAGE_SIZE=$(stat -c%s "$home/Image" 2>/dev/null || stat -f%z "$home/Image")
    FINAL_MD5=$(md5sum "$home/Image" | cut -d' ' -f1)
    ui_print "  ◾️最終カーネルサイズ: $((IMAGE_SIZE / 1024 / 1024))MB"
    ui_print "  ◾️最終カーネルMD5: ${FINAL_MD5:0:16}"
    
    if [ $IMAGE_SIZE -lt 1000000 ]; then
        ui_print " ❌ エラー：カーネルイメージファイルが小さすぎます、破損している可能性があります"
        abort "❌インストール失敗：カーネルイメージが破損しています"
    fi
    ui_print " ✅カーネルイメージ検証成功"
fi

ui_print " "
ui_print " 📥カーネルを書き込み中..."

if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi
ui_print " ✅カーネル書き込み完了！"
ui_print " "
ui_print " "
ui_print " 🐧グループに参加しますか？"
ui_print " ◾️音量上：今すぐ参加"
ui_print " ◾️音量下：もう参加しています"

key_click=""
while [ "$key_click" = "" ]; do
    key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done

case "$key_click" in
    "KEY_VOLUMEUP")
        ui_print " ◾️グループリンクを開いています..."
        am start -a android.intent.action.VIEW -d "https://qun.qq.com/universal-share/share?ac=1&authKey=09GHYeotBX4cNL1o8w%2FF8j%2Bfx%2FcPIU0H5tMp5lO8ZXciwUxETL%2BEwe8gPbaldshS&busi_data=eyJncm91cENvZGUiOiIyODg0ODI5MTgiLCJ0b2tlbiI6InZSOUNTWWx1WVNJNWYrNlpUYWZEQkF4dmpQWVVwZFc1N1REVFFjYmpTR25MYldzTWxnK2NZRXhiVEZkbUtIUE8iLCJ1aW4iOiI0Mjg1NzkifQ%3D%3D&data=WwMC8aE8oVTgoGkPUiXAIs8nMVJZU4UkiWcX8qYMoFoNnTpIwVY7GCCZRX_1UO_Yi8udPzZuE_jESwmq4ABrwQ&svctype=4&tempid=h5_group_info" > /dev/null 2>&1
        ui_print " 💖ご支援ありがとうございます！" 
        ;;
    "KEY_VOLUMEDOWN")
        ui_print " 💖ご支援ありがとうございます！"
        ;;
    *)
        ui_print " 💖ご支援ありがとうございます！"
        ;;
esac
