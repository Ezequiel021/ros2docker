#!/bin/bash
set -e

USERNAME="${1:-ubuntu}"
USER_UID="${2:-1000}"
USER_GID="${3:-1000}"
DEFAULT_HOME="/home/${USERNAME}"
USER_HOME="${4:-$DEFAULT_HOME}"

echo "Configuring user: $USERNAME (UID: $USER_UID, GID: $USER_GID, Home: $USER_HOME)"

if getent group "$USER_GID" > /dev/null; then
    EXISTING_GROUP=$(getent group "$USER_GID" | cut -d: -f1)
    if [ "$EXISTING_GROUP" != "$USERNAME" ]; then
        echo "Renaming existing group $EXISTING_GROUP to $USERNAME"
        groupmod -n "$USERNAME" "$EXISTING_GROUP"
    fi
else
    if getent group "$USERNAME" > /dev/null; then
        echo "Updating existing group $USERNAME to GID $USER_GID"
        groupmod -g "$USER_GID" "$USERNAME"
    else
        echo "Creating new group $USERNAME with GID $USER_GID"
        groupadd -g "$USER_GID" "$USERNAME"
    fi
fi

if getent passwd "$USER_UID" > /dev/null; then
    EXISTING_USER=$(getent passwd "$USER_UID" | cut -d: -f1)
    if [ "$EXISTING_USER" != "$USERNAME" ]; then
        echo "Migrating existing user $EXISTING_USER to $USERNAME"
        usermod -l "$USERNAME" -d "$USER_HOME" -m -g "$USER_GID" "$EXISTING_USER"
    fi
else
    if getent passwd "$USERNAME" > /dev/null; then
        echo "Updating existing user $USERNAME to UID $USER_UID"
        usermod -u "$USER_UID" -g "$USER_GID" -d "$USER_HOME" -m "$USERNAME"
    else
        echo "Creating new user $USERNAME with UID $USER_UID"
        useradd -m -u "$USER_UID" -g "$USER_GID" -d "$USER_HOME" -s /bin/bash "$USERNAME"
    fi
fi

if getent passwd "$USER_UID" > /dev/null; then
    echo "Configuring passwordless sudo for $USERNAME..."
    mkdir -p /etc/sudoers.d
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
    chmod 0440 "/etc/sudoers.d/$USERNAME"
else
    if getent passwd "$USERNAME" > /dev/null; then
        echo "Configuring passwordless sudo for $USERNAME..."
        mkdir -p /etc/sudoers.d
        echo "$USERNAME ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
        chmod 0440 "/etc/sudoers.d/$USERNAME"
    else
        echo "Warning: User creation failed, skipping sudo configuration."
    fi
fi

echo "User configuration completed successfully!"
