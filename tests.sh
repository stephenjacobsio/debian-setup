#!/usr/bin/env bats

# Test if the script runs without errors
@test "Run the setup script without errors" {
  run bash debian_setup.sh
  [ "$status" -eq 0 ]
}

# Test if Docker is installed
@test "Check if Docker is installed" {
  run dpkg -l | grep docker.io
  [ "$status" -eq 0 ]
}

# Test if UFW is active
@test "Verify UFW status" {
  run sudo ufw status
  [[ "$output" =~ "Status: active" ]]
}

# Test if Zsh is installed
@test "Check if Zsh is installed" {
  run dpkg -l | grep zsh
  [ "$status" -eq 0 ]
}

# Test if the SSH configuration has been updated
@test "Check SSH configuration for PermitRootLogin" {
  run grep "^PermitRootLogin no" /etc/ssh/sshd_config
  [ "$status" -eq 0 ]
}

# Test if timezone is set to UTC
@test "Check if timezone is set to UTC" {
  run timedatectl | grep "Time zone"
  [[ "$output" =~ "UTC" ]]
}

# Test if locale is set to en_US.UTF-8
@test "Check if locale is set to en_US.UTF-8" {
  run locale | grep LANG
  [[ "$output" =~ "en_US.UTF-8" ]]
}
