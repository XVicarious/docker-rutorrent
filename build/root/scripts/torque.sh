#!/bin/bash
while [[ $(ps cax | grep nginx) -ne 0 ]]; do
	if [ $DEBUG ]; then
		echo "[Debug] Waiting for nginx to start..."
	fi
	sleep 0.1
done
torque_pid_file=/config/pyrocore/run/pyrotorque.pid
if [ -f $torque_pid_file ]; then
	echo "[Info] Removing old pyrotorque pid file..."
	rm -f $torque_pid_file
fi
echo "[Info] Starting pyrotorque"
pyrotorque --fg
