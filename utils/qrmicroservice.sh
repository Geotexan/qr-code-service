#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd ${SCRIPTPATH}/..

# TODO: Si ya se está ejecutando, ignorar el start, para poder invocarlo cada 5 minutos por cron o algo.

function is_running_app() {
    # Get the PID from text file
    application_pid=$(cat process_id.txt)
    if [[ $? -ne 0 ]]; then
        echo 0
    else
        if ps -p $application_pid > /dev/null; then
            echo $application_pid
        else
            echo 0
        fi
    fi
}

function start_app() {
    # First check.
    local status=$(is_running_app)
    if [ ${status} -ne 0 ]; then
        echo "Process is running. PID ${status}. Aborting..."
        return
    fi
    # Then run.
    echo "Running path --> $(pwd)"
    source ./bin/activate
    nohup ./qr_service &
    # write the pid to text to file to use it later
    app_pid=$!
    echo "Process started with PID $app_pid"
    # wait for process to check proper state, you can change this time accordingly 
    sleep 3
    if ps -p $app_pid > /dev/null; then
        echo "Process successfully running having PID $app_pid"
        # write if success
        echo $app_pid > process_id.txt
        echo "    ✔ DONE."
    else
        echo "Process stopped before reached to steady state"
    fi
}

function stop_app() {
    # Get the PID from text file
    application_pid=$(cat process_id.txt)
    echo "stopping process, Details:"
    # print details
    ps -p $application_pid
    # check if running
    if ps -p $application_pid > /dev/null; then
        # if running then kill else print message
        echo "Going to stop process having PID $application_pid"
        kill -9 $application_pid
        if [ $? -eq 0 ]; then
            echo "Process stopped successfully. Cleaning up..."
            rm process_id.txt nohup.out
            echo "    ✔ DONE."
        else
            echo "Failed to stop process having PID $application_pid"
        fi
    else
        echo "Failed to stop process, process is not running"
    fi
}


case "$1" in 
    start)   start_app ;;
    stop)    stop_app ;;
    restart) stop_app; start_app ;;
    *) echo "usage: $0 start|stop|restart" >&2
       exit 1
       ;;
esac
