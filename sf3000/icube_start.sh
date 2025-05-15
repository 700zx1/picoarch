#!/bin/sh

killall hcprojector
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/mnt/sdcard/cubegm/lib:/mnt/sdcard/cubegm/usr/lib;

LOGFILE="/mnt/sdcard/cubegm/rkgame_log.txt"
REAL_EXEC="/mnt/sdcard/cubegm/pico.bin"
echo "[`date +%H:%M:%S`] [INFO] Script invoked." >> "$LOGFILE"
uname -a >> "$LOGFILE" 2>&1
echo "[`date +%H:%M:%S`] [INFO] Current user: $(whoami)" >> "$LOGFILE"

echo "[`date +%H:%M:%S`] [INFO] Listing available framebuffers..." >> "$LOGFILE"
echo "fbset -fb /dev/fb0" >> "$LOGFILE"
for fb in /dev/fb*; do
  if [ -e "$fb" ]; then
    echo "Framebuffer: $fb" >> "$LOGFILE"
    fbset -fb "$fb" >> "$LOGFILE" 2>&1
  fi
done

# === Framebuffer Configuration ===
FB_DEV="/dev/fb0"
SCREEN_W=480
SCREEN_H=854
LINE_BYTES=1920
BPP=4

# === Snake Parameters ===
SEG_W=10
SEG_H=10
Y=200
SNAKE_LEN=20
STEP=$SEG_W
FRAME_DELAY=50

# === Colors ===
HEAD_A=0xFF
HEAD_R=0x00
HEAD_G=0xFF
HEAD_B=0x00

BODY_A=0xFF
BODY_R=0x00
BODY_G=0x80
BODY_B=0x00

CLR_A=0x00
CLR_R=0x00
CLR_G=0x00
CLR_B=0x00

# === Temporary Files ===
HEAD_SEG="./tmp/head.argb"
BODY_SEG="./tmp/body.argb"
CLEAR_SEG="./tmp/clear.argb"

# === Generate ARGB Blocks ===
gen_block() {
  FILE="$1"
  A=$2 R=$3 G=$4 B=$5
  rm -f "$FILE"
  for i in $(seq 1 $((SEG_W * SEG_H))); do
    printf "\\x$(printf %02x $A)\\x$(printf %02x $R)\\x$(printf %02x $G)\\x$(printf %02x $B)"
  done > "$FILE"
}

# === Blit Block to Screen ===
blit_block() {
  FILE=$1
  X=$2
  Y=$3
  i=0
  while [ $i -lt $SEG_H ]; do
    OFFSET=$(( (Y + i) * LINE_BYTES + X * BPP ))
    dd if="$FILE" bs=$((SEG_W * BPP)) count=1 skip=$i iflag=skip_bytes \
      of=$FB_DEV bs=1 seek=$OFFSET conv=notrunc status=none
    i=$((i + 1))
  done
}

# === Run Animation ===
gen_block "$HEAD_SEG" $HEAD_A $HEAD_R $HEAD_G $HEAD_B
gen_block "$BODY_SEG" $BODY_A $BODY_R $BODY_G $BODY_B
gen_block "$CLEAR_SEG" $CLR_A $CLR_R $CLR_G $CLR_B

MAX_X=$((SCREEN_W - SEG_W))
HEAD=0
X=0

while [ $X -lt $MAX_X ]; do
  if [ $HEAD -ge $SNAKE_LEN ]; then
    TAIL_X=$((X - SNAKE_LEN * STEP))
    blit_block "$CLEAR_SEG" $TAIL_X $Y
  fi

  if [ $HEAD -gt 0 ]; then
    PREV_X=$((X - STEP))
    blit_block "$BODY_SEG" $PREV_X $Y
  fi

  blit_block "$HEAD_SEG" $X $Y

  HEAD=$((HEAD + 1))
  X=$((X + STEP))
  usleep $((FRAME_DELAY * 1000))
done


echo "[`date +%H:%M:%S`] [INFO] Animation complete." >> "$LOGFILE"
echo "[`date +%H:%M:%S`] [INFO] Clearing framebuffer..." >> "$LOGFILE"

# Reset the framebuffer
dd if=/dev/zero of=/dev/fb0

echo "[`date +%H:%M:%S`] [INFO] Proceeding to pico.bin..." >> "$LOGFILE"

if [ ! -x "$REAL_EXEC" ]; then
  echo "[`date +%H:%M:%S`] [ERROR] pico.bin not found or not executable" >> "$LOGFILE"
  exit 1
fi

"$REAL_EXEC" "$@" >> "$LOGFILE" 2>&1
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "[`date +%H:%M:%S`] [INFO] pico.bin exited with code $EXIT_CODE after ${DURATION}s" >> "$LOGFILE"

if [ -x /mnt/sdcard/cubegm/busybox ]; then
  echo "[`date +%H:%M:%S`] [INFO] Launching Busybox shell..." >> "$LOGFILE" 2>&1
  /mnt/sdcard/cubegm/busybox sh
  exit $?
else
  echo "[`date +%H:%M:%S`] [INFO] Busybox shell not found. Continue to icube &" >> "$LOGFILE"
  /mnt/sdcard/cubegm/icube &
fi
