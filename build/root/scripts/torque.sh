#!/bin/bash
torque_pid_file=/config/pyrocore/run/pyrotorque.pid
if [ -f $torque_pid_file ]; then
	echo "[Info] Removing old pyrotorque pid file..."
	rm -f $torque_pid_file
fi
echo "[Info] Starting pyrotorque"
pyrotorque --fg
