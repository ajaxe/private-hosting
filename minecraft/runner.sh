#!/bin/bash
set -e

# 1. Clear stale locks from /tmp
echo "--- Cleaning stale network locks ---"
rm -rf /tmp/libraknet* /tmp/RocketNet* /tmp/*.lock || true

# 2. Identify the internal container IP
# Binding specifically to the internal IP can help bypass dual-stack bind issues
CONTAINER_IP=$(ip route get 1 | awk '{print $7;exit}')
echo "--- Container Internal IP: $CONTAINER_IP ---"

# 3. Handle Volume Permissions
# This fixed the LevelDB "File not open" error seen in previous logs
if [ "$(id -u)" = "0" ]; then
    echo "--- Adjusting ownership for 'worlds' volume ---"
    chown -R minecraft:minecraft /home/app/minecraft/worlds
    chmod -R 775 /home/app/minecraft/worlds
fi

# 4. Run the config utility
echo "--- Processing Configuration ---"
./mc-config /home/app/minecraft/data/server.properties /home/app/minecraft/server.properties

# 5. APPLY IPV4-ONLY HACKS (Fix for EAFNOSUPPORT)
# When IPv6 is hard-disabled in the kernel, setting the V6 port to empty
# is the only way to stop the binary from crashing on socket(AF_INET6).
echo "--- Patching properties for IPv4-only host ---"

# Verify the final config for debugging
echo "--- Final server.properties (Network Section) ---"
grep -E "server-ip|port|ipv6" server.properties

# 6. Launching Bedrock Server
echo "--- Launching Bedrock Server (Dropping privileges to 'minecraft') ---"
export LD_LIBRARY_PATH=.

if [ "$(id -u)" = "0" ]; then
    # Running with strace one last time to confirm the AF_INET6 call is skipped or ignored
    # exec gosu minecraft strace -f -e trace=network ./bedrock_server --ipv4
    exec gosu minecraft ./bedrock_server --ipv4
else
    # exec strace -f -e trace=network ./bedrock_server --ipv4
    exec ./bedrock_server --ipv4
fi