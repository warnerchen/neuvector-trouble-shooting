# Disable NeuVector nvprotect

NeuVector has an internal protection mechanism called nvprotect, which restricts user access to NeuVector pods.

If you need to disable it, you can do so via the API. This script is provided to support disabling nvprotect for the Controller, Scanner, and Enforcer.

Usage:

```bash
# Disable nvprotect
# Disabling the Enforcer will also disable the Scanner's nvprotect.
./disable-nvprotest.sh off controller|enforcer

# Enable nvprotect
./disable-nvprotest.sh on controller|enforcer
```
