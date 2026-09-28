import os, glob
# find QEMU dir broadly: look for kaihong-serial.log or launch_qemu anywhere on D:
for pat in [r'D:/*kaihong*/**/launch_qemu*.cmd', r'D:/qemu*/**/launch_qemu*.cmd', r'C:/Users/hongfu/*qemu*/**/launch_qemu*.cmd']:
    for p in glob.glob(pat, recursive=True)[:3]:
        print(p)
# common spots
for d in [r'D:/QEMU_DIR', r'D:/qemu', r'C:/QEMU_DIR', r'D:/vms', r'D:/VMs', r'D:/uniterm/vms']:
    if os.path.exists(d):
        print('exists:', d, os.listdir(d)[:10])
