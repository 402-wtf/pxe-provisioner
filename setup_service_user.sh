#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Halting. Script must run as root."
  exit 1
fi

username="ansible"
authorized_key_text="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD4GeKHuw9LLjwaozWd+6it0DmbDle5FymGuidZfkBLfuQCwj2hz9W2bgwCYNddSZcGgGZmjq9Fq7QdQiUA0bEs3nWZLSGIsRlodRV1SH6W7pUgBYoanWSc12LPaaKMO/rpAZlOqOm3+EE4pB+r2PllETSFsYNukHOy7yrkfsebgZxWPsSzDmfGE2X7BhwIUisA86+QzbKltnKSD3W5G36NGWOZdgSSLTmgQfEPell98RAKSVSZsNFvBIYN33uIP/zLCOvFOk21qFilemu3MKqGyf7lKdFHCWVmhL6Zp6rQYmrdznOMXt32jTtJeVSZSAD5LkO6qQJg5tzgX7qTGAOOL+cp2DinG5uxEy0Vjel4Tf37xRH8FjoVj0IPZn4tjnGkbT9nKVRLJXdsQAp/YF6IZRnYJn0cGQ3fEa3gHzJifYPLfhimaOdMnxrMS9RZX3owNE6f+FwN1Dulme+AFiCb3W+thNDTKqRzTzkU+32vWYoQXQMFrGaKs4Iqa/215dv5pT75j1OlR2w82jDc7ZlVmP5tNo9MonmMYP0+EMx0EbMfESOb3MGD7GeGesXOG+NHr5cA9g8ILWqRoiCtJTbCAj+HrHsX08XO2X8J5+bPjBTfVhkGMMM5JOg1wbFB9qPBZPLbwiWv/2Uq1pWZfBJqPaOkWirEyB4zRkLx+O2MYQ=="
getent group sudo || groupadd sudo
if id "$username" &>/dev/null; then
  echo "User already exists, not running."
  if [ $(stat -c "%U" "/opt/$username/.ssh/authorized_keys") != "$username" ]; then
    echo "Fixing ownership mismatch..."
    chown -R $username:users /opt/$username
  fi
  if [ $(stat -c "%a" "/opt/$username/.ssh/authorized_keys") != "600" ]; then
    echo "Fixing ownership mismatch..."
    chmod 600 /opt/$username/.ssh/authorized_keys
  fi
  if grep -qv "$authorized_key_text" "/opt/$username/.ssh/authorized_keys"; then
    echo "Key not found in authorized keys. Did you run this from another executor?"
    echo "Adding current executor key."
    echo "$authorized_key_text" >> /opt/$username/.ssh/authorized_keys
  fi
else
  useradd -G sudo -s /bin/bash -m -d /opt/$username $username
  mkdir -p /opt/$username/.ssh
  chmod 700 /opt/$username/.ssh
  echo "$authorized_key_text" >> /opt/$username/.ssh/authorized_keys
  chmod 600 /opt/$username/.ssh/authorized_keys
  chown -R $username:users /opt/$username
  echo "$username ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$username"
fi
echo "Setup $username completed."

if ! command -v python &> /dev/null
then
    echo "Python could not be found. Attempting to install"
    if command -v pacman &> /dev/null
    then
      pacman -Sy --noconfirm python
      echo "Python installed with pacman"
    fi
    if command -v yum &> /dev/null
    then
      yum install -y python
      echo "Python installed with yum"
    fi
    if command -v apt-get &> /dev/null
    then
      apt-get install -y python
      echo "Python installed with apt-get"
    fi
fi
exit 0
