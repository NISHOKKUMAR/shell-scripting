#!/bin/bash

# create a new user
create_user() {
    echo "Enter the username of the new user:"
    read username

    # Create the user and set default shell to bash
    sudo useradd -m -s /bin/bash "$username"
    
    # Set the password for the user
    echo "Enter password for $username:"
    sudo passwd "$username"
    
    # Optionally, add the user to a group (if required)
    echo "Enter group name to add user to (Leave blank if none):"
    read group
    if [ -n "$group" ]; then
        sudo usermod -aG "$group" "$username"
        echo "$username added to group $group."
    fi

    echo "User $username created successfully!"
}

# delete a user
delete_user() {
    echo "Enter the username to delete:"
    read username

    # Delete the user and their home directory
    sudo userdel -r "$username"
    
    echo "User $username deleted successfully!"
}

# create a new group
create_group() {
    echo "Enter the group name to create:"
    read groupname
    
    # Create the new group
    sudo groupadd "$groupname"
    
    echo "Group $groupname created successfully!"
}

# assign permissions
assign_permissions() {
    echo "Enter the file or directory path to assign permissions to:"
    read filepath

    echo "Enter the username to assign permissions to:"
    read username

    echo "Enter the permission type (r = read, w = write, x = execute):"
    read permission

    # Check if the file or directory exists
    if [ -e "$filepath" ]; then
        sudo chmod u+$permission "$filepath"
        sudo chown "$username":"$username" "$filepath"
        echo "Permission $permission granted to $username for $filepath."
    else
        echo "The specified file/directory does not exist!"
    fi
}

# list users and groups
list_users_groups() {
    echo "List of users:"
    cut -d: -f1 /etc/passwd
    
    echo "List of groups:"
    cut -d: -f1 /etc/group
}

# Main Menu
echo "User and Permission Management Script"

while true; do
    echo "Choose an option:"
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. Create Group"
    echo "4. Assign Permissions"
    echo "5. List Users/Groups"
    echo "6. Exit"
    
    read OPTION

    if [[ $OPTION -eq 1 ]]; then
        create_user
    elif [[ $OPTION -eq 2 ]]; then
        delete_user
    elif [[ $OPTION -eq 3 ]]; then
        create_group
    elif [[ $OPTION -eq 4 ]]; then
        assign_permissions
    elif [[ $OPTION -eq 5 ]]; then
        list_users_groups
    elif [[ $OPTION -eq 6 ]]; then
        echo "Exiting script..."
        break
    else
        echo "Invalid option. Please try again."
    fi
done
