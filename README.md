# Limes

Limes provides an easy work flow with MFA protected access keys, temporary credentials and access to multiple roles/accounts.

Limes is the Local Instance MEtadata Service and emulates parts of the [AWS Instance Metadata Service](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) running on Amazon Linux. The AWS SDK and AWS CLI can therefor utilize this service to authenticate.

## Attribution

This project is a continuation of [otm/limes](https://github.com/otm/limes) - a fantastic tool that has served me well for many years. Due to no additional maintenance of this tool - this fork has been created.

## Warning

The AWS SDK refreshes credentials automatically when using limes. So **all** services will change profile if the profile is changed in limes.

## Installation

1. Download binary for your architecture from https://github.com/alexejk/limes/releases/latest
2. Copy the file to `/usr/local/bin` or appropriate location in PATH
3. Make it executable: `chmod +x /usr/local/bin/limes`
4. **Linux:** Allow limes to bind to privileged ports `setcap 'cap_net_bind_service=+ep' /usr/local/bin/limes`

**Note:** On Mac OS limes server is needed to run as root for the time being.

## Configuring the Loop Back Device

The configuration below adds the necessary IP configuration on the loop back device. Without this configuration the service can not start.

**Note:** This configuration is not persistent between reboots.

### Linux

```shell
sudo ip addr add 169.254.169.254/24 broadcast 169.254.169.255 dev lo:metadata
sudo ip link set dev lo:metadata up
```

### Mac

```shell
sudo /sbin/ifconfig lo0 alias 169.254.169.254
```

## Configuring IMS (Instance Meta-data Service)

There is an [example configuration file](https://github.com/alexejk/limes/blob/master/config.example). The configuration file is documented. Make a copy of the file and place it in `~/.limes/config`.

```shell
mkdir -p ~/.limes
wget -O ~/.limes/config https://raw.githubusercontent.com/otm/limes/master/config.example
```

Use your favorite text editor to update ~/.limes/config

## Usage

Running `limes` in your terminal prints usage information.

### Starting the Service

The service is started with `limes start`.

### Assuming Profiles

A profile is assumed with `limes assume <profile-name>`, where profile-name is a configured profile. Please note that this does not refer to AWS profiles but profiles configured in limes.

### Running Applications with Alternate Profile

If you have assumed a role on limes you might want to run an application once with an alternate profile. This is possible without assuming the profile with the `run` subcommand.

```shell
limes --profile <name> run <application> [args...]
```

**Tip**
With `limes --profile <name> run bash` it is possible to quickly start a shell with exported environment variables that is valid for an hour.

### Protected Profiles

By adding `protected: true` to your profile it will not be possible to assume that role. It will only be possible to utilize the subcommands `run` and `env`.

### Service Status

By running `limes status` it is possible to see the current status, and also it can detect common problems and misconfiguration.

## Known Problems

If AWS environment variables, `.aws/credentials` or `.aws/config` are present there is a chance that the limes does not work. This can be checked with `limes status`.

## Security

The service should be configured on the loop back device, and only accessible from the host it is running on.

**Note:** It is important not to run any service that could forwards request on the host running Limes as this would be a security risk. However, this is no difference from the setup on an Amazon Linux instance in AWS. If an attacker could forward requests to 169.254.169.254/24 your credentials could be compromised. Please note that an attacker could utilize a DNS to resolve to this address, so always be aware where you forward requests to.  

## Build

To build you need a Go compiler and environment setup. See https://golang.org/ for more information regarding setting up and configuring Go. You may also fully rely on Docker instead. Additional dependencies include `make`.

Building with make:

```shell
go get github.com/alexejk/limes
make all
```

Building with docker:

```shell
make build-in-docker
```