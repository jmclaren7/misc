#!/bin/bash
mkdir -m 700 ~/.ssh; curl https://raw.githubusercontent.com/jmclaren7/misc/refs/heads/master/JCS2025ED2 >> ~/.ssh/authorized_keys
SSHD_CONFIG_FILE="/etc/ssh/sshd_config"
cp "${SSHD_CONFIG_FILE}" "${SSHD_CONFIG_FILE}.bak_$(date +%Y%m%d%H%M%S)"
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "${SSHD_CONFIG_FILE}"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "${SSHD_CONFIG_FILE}"
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "${SSHD_CONFIG_FILE}"
sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' "${SSHD_CONFIG_FILE}"
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' "${SSHD_CONFIG_FILE}"
sshd -t
if [ $? -eq 0 ]; then
    echo "sshd_config syntax check passed. Restarting SSH service..."
    # Restart the SSH service to apply changes
    systemctl restart sshd || service sshd restart || /etc/init.d/ssh restart
    echo "SSH service restarted. Key-only authentication should now be enforced."
else
    echo "sshd_config syntax check failed. Please review the changes in ${SSHD_CONFIG_FILE}."
    echo "The SSH service was NOT restarted to prevent potential lockout."
fi
