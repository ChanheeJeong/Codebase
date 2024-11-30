# This is an initial setup shell script for rpi based ipkvm

echo "Starting Initial Setup Shell Script..."

read -p "Do you wish to continue with initial setup? Yes(Y)/No(n): " choice
case $choice in
    [yY]* ) echo "Starting Initial Setup";;
    [nN]* ) echo "Setup cancelled"; exit;;
esac

echo "Check if the following lines are added at the end of /boot/firmware/config.txt"
echo "dtoverlay=tc358743,4lane=1"
echo "dtoverlay=tc358743-audio"
read confirm_01

echo "Check if the following file is saved at /home/user/1080P60EDID.txt"
read confirm_02

# Check video devices list
echo "Checking video devices list... Please check rpi media number"
v4l2-ctl --list-devices
read confirm_03

# Load EDID data and check screen resolution
v4l2-ctl -d /dev/v4l-subdev2 --set-edid=file=/home/chanheejeong/1080P60EDID.txt --fix-edid-checksums
echo "Checking screen resolution"
v4l2-ctl -d /dev/v4l-subdev2 --query-dv-timings
read confirm_04

# Apply screen timing to capture and reset links
v4l2-ctl -d /dev/v4l-subdev2 --set-dv-bt-timings query
media-ctl -d /dev/media0 -r

# Set formats
media-ctl -d /dev/media0 -l ''\''csi2'\'':4 -> '\''rp1-cfe-csi2_ch0'\'':0 [1]'
media-ctl -d /dev/media0 -V ''\''csi2'\'':0 [fmt:RGB888_1X24/1920x1080 field:none colorspace:srgb]'
media-ctl -d /dev/media0 -V ''\''csi2'\'':4 [fmt:RGB888_1X24/1920x1080 field:none colorspace:srgb]'
v4l2-ctl -v width=1920,height=1080,pixelformat=RGB3

# Capturing frames
echo "Creating stream object .yuv..."
v4l2-ctl --verbose -d /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat='RGB3' --stream-mmap=4 --stream-skip=3 --stream-count=2 --stream-to=csitest.yuv --stream-poll

