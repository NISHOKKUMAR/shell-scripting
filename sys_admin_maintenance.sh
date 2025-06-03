#!/bin/bash

# Log file for tracking all script activities. It's a good practice to have logs
# for any automation tasks in order to easily trace issues or confirm the script's execution.
LOG_FILE="/var/log/sys_admin_maintenance.log"

# Function to check disk usage and send an alert if it exceeds the threshold
check_disk_usage() {
    # This will check the disk usage on all mounted file systems
    echo "Checking disk usage..." | tee -a $LOG_FILE
    df -h | grep -E '^/dev/' | while read line; do
        # Extracting the disk usage percentage from the output and comparing
        usage=$(echo $line | awk '{print $5}' | sed 's/%//')
        if [ "$usage" -gt 80 ]; then
            # If disk usage is greater than 80%, log a warning message
            echo "Warning: Disk usage is above 80% on $(echo $line | awk '{print $1}') - $usage%" | tee -a $LOG_FILE
        fi
    done
}

# Function to check CPU usage and alert if it's too high
check_cpu_usage() {
    # This checks the CPU usage of the system
    echo "Checking CPU usage..." | tee -a $LOG_FILE
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        # If CPU usage is above 80%, log a warning
        echo "Warning: CPU usage is above 80% - $cpu_usage%" | tee -a $LOG_FILE
    else
        # If CPU usage is normal, log that it's working fine
        echo "CPU usage is normal: $cpu_usage%" | tee -a $LOG_FILE
    fi
}

# Function to check memory usage and alert if it's too high
check_memory_usage() {
    # Checking memory usage to ensure the system is not using too much RAM
    echo "Checking memory usage..." | tee -a $LOG_FILE
    memory_usage=$(free -h | awk 'NR==2{printf "%.2f", $3*100/$2 }')
    if (( $(echo "$memory_usage > 80" | bc -l) )); then
        # If memory usage is too high, log a warning
        echo "Warning: Memory usage is above 80% - $memory_usage%" | tee -a $LOG_FILE
    else
        # If memory usage is within limits, log that everything is fine
        echo "Memory usage is normal: $memory_usage%" | tee -a $LOG_FILE
    fi
}

# Function to update system packages (keeping things secure and up to date)
update_system() {
    # It's crucial to keep the system updated, so this function updates all packages
    echo "Updating system packages..." | tee -a $LOG_FILE
    sudo apt update -y >> $LOG_FILE 2>&1
    sudo apt upgrade -y >> $LOG_FILE 2>&1
    # After update, confirm it was completed
    echo "System packages updated successfully." | tee -a $LOG_FILE
}

# Function to perform log rotation (cleanup)
rotate_logs() {
    # It's important to regularly rotate logs to free up disk space
    echo "Rotating logs..." | tee -a $LOG_FILE
    sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; >> $LOG_FILE 2>&1
    # Confirming that the logs have been rotated successfully
    echo "Log rotation completed." | tee -a $LOG_FILE
}

# Function to backup critical system files and directories (essential for disaster recovery)
backup_system() {
    # Creating a backup directory with the current date to ensure backups are easy to find
    BACKUP_DIR="/backup/$(date +%F)"
    echo "Backing up critical files to $BACKUP_DIR..." | tee -a $LOG_FILE
    sudo mkdir -p $BACKUP_DIR
    # Copying system files that are important for system recovery (like /etc, /home, and /var/log)
    sudo cp -r /etc $BACKUP_DIR/etc >> $LOG_FILE 2>&1
    sudo cp -r /var/log $BACKUP_DIR/logs >> $LOG_FILE 2>&1
    sudo cp -r /home $BACKUP_DIR/home >> $LOG_FILE 2>&1
    # Confirming the backup is complete
    echo "Backup completed successfully at $BACKUP_DIR" | tee -a $LOG_FILE
}

# Main function to perform all tasks sequentially
perform_maintenance() {
    # Starting the maintenance tasks and logging the start time
    echo "Starting system maintenance tasks..." | tee -a $LOG_FILE
    check_disk_usage
    check_cpu_usage
    check_memory_usage
    update_system
    rotate_logs
    backup_system
    # Indicating the maintenance tasks have been completed
    echo "System maintenance tasks completed." | tee -a $LOG_FILE
}

# Execute the maintenance function
perform_maintenance
