#!/bin/bash
SSH_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTKGXa8QR0VI0hD2Nv/hgwObKmJEUki+VjuCsNLIcER JCS2025ED2"
AUTHORIZED_KEYS_FILE="${HOME}/.ssh/authorized_keys"
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

ensure_ssh_directory() {
    mkdir -p -m 700 "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh"
}

add_public_key() {
    local public_key="$1"

    ensure_ssh_directory
    touch "${AUTHORIZED_KEYS_FILE}"

    if grep -qxF "${public_key}" "${AUTHORIZED_KEYS_FILE}"; then
        echo "Public key already exists in ${AUTHORIZED_KEYS_FILE}."
    else
        echo "${public_key}" >> "${AUTHORIZED_KEYS_FILE}"
        echo "Public key added to ${AUTHORIZED_KEYS_FILE}."
    fi

    chmod 600 "${AUTHORIZED_KEYS_FILE}"
}

install_key() {
    add_public_key "${SSH_PUBLIC_KEY}"
}

update_sshd_config() {
    cp "${SSHD_CONFIG_FILE}" "${SSHD_CONFIG_FILE}.bak_$(date +%Y%m%d%H%M%S)"
    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "${SSHD_CONFIG_FILE}"
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "${SSHD_CONFIG_FILE}"
    sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "${SSHD_CONFIG_FILE}"
    sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' "${SSHD_CONFIG_FILE}"
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' "${SSHD_CONFIG_FILE}"

    if sshd -t; then
        echo "sshd_config syntax check passed. Restarting SSH service..."
        systemctl restart sshd || service sshd restart || /etc/init.d/ssh restart
        echo "SSH service restarted. Key-only authentication should now be enforced."
    else
        echo "sshd_config syntax check failed. Please review the changes in ${SSHD_CONFIG_FILE}."
        echo "The SSH service was NOT restarted to prevent potential lockout."
    fi
}

generate_key() {
    local key_file="${HOME}/.ssh/id_ed25519_$(date +%Y%m%d%H%M%S)"
    local default_key_comment="JCS2025ED2"
    local key_comment

    if [ ! -r /dev/tty ]; then
        echo "Unable to prompt for key details because no terminal is available."
        return 1
    fi

    read -r -p "Enter key comment [${default_key_comment}]: " key_comment < /dev/tty
    key_comment="${key_comment:-$default_key_comment}"

    ensure_ssh_directory
    ssh-keygen -t ed25519 -C "${key_comment}" -f "${key_file}" < /dev/tty

    if [ $? -ne 0 ]; then
        echo "Key generation failed."
        return 1
    fi

    add_public_key "$(cat "${key_file}.pub")"

    echo "Private key (${key_file}):"
    cat "${key_file}"
}

get_choice() {
    if [ -n "$1" ]; then
        choice="$1"
        return 0
    fi

    if [ -r /dev/tty ] && read -r -p "Enter choice [1-4]: " choice < /dev/tty; then
        return 0
    fi

    echo "Unable to read a selection. Run this script from a terminal or pass a choice as the first argument."
    echo "Example: bash JCS2025ED2.sh 3"
    exit 1
}

echo "Choose an option:"
echo "1) Install key"
echo "2) Update sshd config"
echo "3) Install key and update sshd config"
echo "4) Generate a key"
get_choice "$1"

case "${choice}" in
    1)
        install_key
        ;;
    2)
        update_sshd_config
        ;;
    3)
        install_key
        update_sshd_config
        ;;
    4)
        generate_key
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac
