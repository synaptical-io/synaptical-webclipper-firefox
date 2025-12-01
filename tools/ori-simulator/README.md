# Ori Simulator 

Ori Simulator is essentially a fancy echo server to assist in debugging Synaptical WebClipper.

For FireFox NativeMessaging, a manifest file must be copied into its NativeMessaging directory.
The following scripts generate and write the appropriate manifest file, which points to
the ori-simulator.py so your extension can "talk" to it.

1. `chmod +x ./tools/ori-simulator/{*.sh,*.py}`
2. `./tools/ori-simulator/enable-ori-simulator.sh`
3. `./tools/ori-simulator/ori-simulator.py`
4. `Ctrl-C to quit`

### Optional
`tail -n 20 ./logs/ori-simulator.log
