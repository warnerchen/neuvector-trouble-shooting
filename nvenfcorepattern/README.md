NeuVector Enforcer Core Pattern

When the NV Enforcer Pod restarts due to OOM, you can use this script to temporarily configure a core dump for the NV Enforcer Pod.

Usage:

```bash
# Enable
# After enabling, you can find the core dump file in the /tmp folder of the NV Enforcer Pod.
./nvenfcorepattern.sh on

# Disable
./nvenfcorepattern.sh off
```
