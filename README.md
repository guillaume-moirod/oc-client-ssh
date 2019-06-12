# OC-SSH-CLIENT

This image was intended for use with XL Release Openshift Integration

# How to use

```bash
docker run -d -p 2222:2222 sonikro/oc-client-ssh:3.11.4

## Password is password
ssh sshworker@localhost -p 2222
## Now you're able to use openshift CLI
```
