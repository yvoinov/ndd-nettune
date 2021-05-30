# NDD NetTune SMF

## Usage

The service is intended for setting and keep custom values of the parameters of the TCP stack between reboots on Solaris 10/11.

To install, run the script:
```sh
nettune_smf_inst.sh
```
To remove, run the script:
```sh
nettune_smf_rmv.sh
```

The service is installed enabled. To configure, change the values in /etc/ndd.conf and restart the service.
