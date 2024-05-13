#!/bin/sh

# Ensure environment variables are exported
export SOAPY_REMOTE_IP_ADDRESS=[::]
export SOAPY_REMOTE_PORT=55132

# Wait for Avahi to be ready, if necessary
# This check can be a loop or a single line command depending on your implementation
if avahi-daemon -c; then
    echo "Avahi is running, starting SoapySDRServer..."
    # Run SoapySDRServer with gosu to switch to 'soapysdr' user
    exec gosu soapysdr /usr/bin/SoapySDRServer --bind="${SOAPY_REMOTE_IP_ADDRESS}:${SOAPY_REMOTE_PORT}"
else
    echo "Failed to confirm Avahi is running."
    exit 1
fi
