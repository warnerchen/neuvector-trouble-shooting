# Disable NeuVector nvprotect

NeuVector has an internal protection mechanism called nvprotect, which restricts user access to NeuVector pods.

If you need to disable it, you can do so via the API. This script is provided to support disabling nvprotect for the Controller, Scanner, and Enforcer.

Usage:

```bash
git clone https://github.com/warnerchen/disable-nvprotect.git
cd disable-nvprotect
chmod +x script.sh

# Disable nvprotect
# Disabling the Enforcer will also disable the Scanner's nvprotect.
./script.sh off controller|enforcer

# Enable nvprotect
./script.sh on controller|enforcer
```
