#!/bin/bash
x=rs-chrony-makestep.service
cat > /etc/systemd/system/"$x" <<'EOF'
[Unit]
Description=Force chrony to synchronize (makestep) system clock
After=chronyd.service
Requires=chronyd.service
Before=time-sync.target
Wants=time-sync.target

[Service]
Type=oneshot
ExecStart=/usr/bin/chronyc -a makestep
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl enable "$x"
systemctl start "$x"
