#!/system/bin/busybox sh

# This script is suitable for sourcing from another script.
# NOTE: kernel is also patched from /etc/fix_ttl.sh

PAGEMAP="$(awk '/r page00/ {print "0x"$1;exit}' /proc/kallsyms)"

function wr_m() {
    local i
    local dst
    local src

    dst=$(( ${1} ))
    shift
    for i in "$@";
    do
        src=$(( $PAGEMAP + 0x${i} ))
        ecall strncpy $dst $src 1 || true
        dst=$(( $dst + 1 ))
    done
}

if [[ "$1" == "boot" ]];
then
    # Patch datalock
    DATALOCK_ADDR="$(awk '/ g_bAtDataLocked/ {print "0x"$1;exit}' /proc/kallsyms)"
    if [[ "$DATALOCK_ADDR" ]];
    then
        # write zero to g_bAtDataLocked byte
        wr_m $DATALOCK_ADDR 00
        echo "Datalock patched"
    fi

    # Patch nv_readEx
    NV_READEX_ADDR="$(awk '/ nv_readEx/ {print "0x"$1;exit}' /proc/kallsyms)"
    if [[ "$NV_READEX_ADDR" ]];
    then
        NV_READEX_PATCH_OFFSET=$(($NV_READEX_ADDR + 0x54))
        # BLS loc_C0227A84 to NOP
        wr_m $NV_READEX_PATCH_OFFSET 00 00 A0 E1
        echo "nv_readEx patched"
    fi

    # Patch nv_writeEx
    NV_WRITEEX_ADDR="$(awk '/ nv_writeEx/ {print "0x"$1;exit}' /proc/kallsyms)"
    if [[ "$NV_WRITEEX_ADDR" ]];
    then
        NV_WRITEEX_PATCH_OFFSET=$(($NV_WRITEEX_ADDR + 0x4C))
        # BLS loc_C0227EE0 to NOP
        wr_m $NV_WRITEEX_PATCH_OFFSET 00 00 A0 E1
        echo "nv_writeEx patched"
    fi

    # Allow loading modules without signature
    # As older kernel versions without X.509 signature support do not have
    # load_module function, this patch should be safe.
    LOAD_MODULE_ADDR="$(awk '/ load_module/ {print "0x"$1;exit}' /proc/kallsyms)"
    if [[ "$LOAD_MODULE_ADDR" ]];
    then
        LOAD_MODULE_PATCH_OFFSET=$(($LOAD_MODULE_ADDR + 0xDC))
        # BNE to no_signature
        wr_m $LOAD_MODULE_PATCH_OFFSET 09 00 00 1A
        echo "load_module patched"
    fi
fi
