# netlabel tools

Domain of Interpretation (DOI)

The RFC likes to define values against a DOI but it's ultimately user defined.

DOI -> Selinux Domain

The CIPSO and CALIPSO mention that category could have special values to
be interpreted for automatic releasablity. Likely few if any implement that.

## Commericial Internet Protocol Security Option (CIPSO) IPv4

IP option 134
Max 40 16 bit words

Tag types 1, 2, and 5 are defined.

Type 1 bitmapped
Sensitivity is an 8 bit integer 0-255. 255 is max sensitivity.
Category is a bitmap. 0-30 octets in big endian.

Type 2 enumerated
Sensitivity is an 8 bit integer 0-255
Category is a 2 octet (16 bit) integer 0-65534. (65535 is reserved) Up to 15 categories.

Type 5 range
Sensitivity is an 8 bit integer 0-255
Category is 2 octets high category and 2 octets low category (4 octets) 0-65534
Range is inclusive with up to 7 pairs. Category has 65535 reserved.

## Common Architecture Label IPv6 Security Option (CALIPSO) IPv6

IP hop by hop option 7 or 0x07 or 00000111

Compartment Size
0-255 32 bit words

Domain of Interpretation
1 32 bit word normally printed in 4 octets 0:0:0:0

Sensitivity
1 8 bit word
User defined, but 255 is highest sensitivity

Compartment Bitmap
Variable number of 64 bit words as per Compartment Size
Bitmap contents is user defined

```text
In netlabel implementation, one tag type (so don't specify tag type) and
passthrough only. (no map translation)
May not have local mode either with full selinux context (not sure).
```

## selinux context

```bash
unconfined_u:object_r:user_home_t:s0
user
role
type
context

context is further sensitivity:level
sensitivity is a range
level is a multiple selection but applications may treat it as a range
s0-100
c0.c100
c1,c2,c5,c7.c300
```

```bash
netlabel maps
Domain -> ping_t
Sensitivity -> s0
Category -> c100

user and role are a running process thing
```

## netlabelctl cipso

```bash
netlabelctl mgmt protocols

# Associate DOI 5 with selinux domain ping_t
# Does it only use selinux type field?
netlabelctl cipso add local doi:100
netlabelctl cipso add pass doi:102 tags:1,2,5

netlabelctl cipso del doi:100

# Remap doi sensitivity levels and categories
# Left is local, right is on wire
netlabelctl cipso add pass doi:102 tags:1,2,5 levels:1=2,3=4,5=6 categories:10=11,12=13,14=15

# Allow unlabeled traffic at all
netlabelctl unlbl accept on
netlabelctl unlbl accept off
netlabelctl unlbl list

# Set unlabeled domain selinux label
netlabelctl unlbl add default address:1.2.3.4 label:system_u:object_r:unlabeled_t:s0
netlabelctl unlbl del default address:1.2.3.4

# Set unlabeled domain
netlabelctl map add domain:test protocol:unlbl
netlabelctl map del domain:test

# Set IP address range to selinux domain
netlabelctl map add domain:test address:0.0.0.0/0 protocol:unlbl

netlabelctl map add domain:ping_t protocol:cipsov4,5
```

## netlabelctl calipso

```bash
netlabelctl calipso add pass doi:100
# There is only one format for calipso so no tag types
# Use the netlabelctl map add and such as before
```

## Tests

### Client not configured and server configured

```bash
# netse1 client 10.21.1.100
netlabelctl map list
domain:DEFAULT,UNLABELED

nc -v 10.21.1.101 20
Ncat: Version 7.92 ( https://nmap.org/ncat )
Ncat: Protocol error.

# netse2 server 10.21.1.101
netlabelctl cipsov4 add pass doi:1 tags:1
netlabelctl map del default
netlabelctl map add default protocol:cipsov4,1
netlabelctl map list
domain:DEFAULT,CIPSOv4,1

chargen -l 20
10.21.1.101 sends an ICMP parameter problem to 10.21.1.100
ICMP has a CIPSO DOI 1 type 1 bitmap set to 0
```

### Client configured and server not configured

```bash
# netse1 client 10.21.1.100
netlabelctl cipsov4 add pass doi:1 tags:1
netlabelctl map del default
netlabelctl map add default protocol:cipsov4,1
netlabelctl map list
domain:DEFAULT,CIPSOv4,1

nc -v 10.21.1.101 20
Ncat: Version 7.92 ( https://nmap.org/ncat )
Ncat: Protocol error.

10.21.1.100 Sends an ICMP parameter problem to 10.21.1.101
ICMP has a CIPSO DOI 1 type 1 bitmap set to 0

# netse2 server 10.21.1.101
netlabelctl map list
domain:DEFAULT,UNLABELED

chargen -l 20
```

### Client configured and server configured

```bash
# Run default DOI 1 on both client and server
# TCP connects and works as expected
# Wireshark shows CIPSO option 134 on TCP stream
```

### Netcat to getpeercon_server test

Make sure selinux is in enforcing mode.

```bash
# Local domain apache_t sends everything in cipso doi 16
netlabelctl map add domain:apache_t protocol:cipsov4,16

# Local domain firefox_t sends cipso doi 17 to ip addresses on 10.0.0.0/8
netlabelctl map add domain:firefox_t address:10.0.0.0/8 protocol:cipsov4,17

# You can't add the same DOI to local and passthrough. Must be different DOI numbers.
# On both netse1 10.21.1.100 and netse2 10.21.1.101
netlabel-config reset
netlabelctl cipso add local doi:100
netlabelctl cipso add pass doi:101 tags:1,2,5
netlabelctl map del default
# netlabelctl map add default protocol:unlbl
# netlabelctl map add default protocol:cipso,100
netlabelctl map add domain:unconfined_t address:0.0.0.0/0 protocol:unlbl
# netlabelctl map add domain:firefox_t address:192.168.1.0/24 protocol:unlbl
netlabelctl map add domain:unconfined_t address:10.21.0.0/16 protocol:cipso,101
netlabelctl map add domain:unconfined_t address:10.22.0.0/16 protocol:cipso,101
netlabelctl -p cipso list
netlabelctl -p map list

Configured CIPSO mappings (2)
 DOI value : 100
   mapping type : LOCAL
 DOI value : 101
   mapping type : PASS_THROUGH
Configured NetLabel domain mappings (1)
 domain: "unconfined_t" (IPv4)
   address: 10.21.0.0/16
    protocol: CIPSO, DOI = 101
   address: 10.22.0.0/16
    protocol: CIPSO, DOI = 101
   address: 0.0.0.0/0
    protocol: UNLABELED

[root@netse1 ~]# nc -v 10.21.1.101 1030
Ncat: Version 7.92 ( https://nmap.org/ncat )
Ncat: Connected to 10.21.1.101:1030.
^C

[root@netse1 ~]# ping 10.21.1.101
PING 10.21.1.101 (10.21.1.101) 56(84) bytes of data.
64 bytes from 10.21.1.101: icmp_seq=1 ttl=64 time=1.47 ms
unknown option 86
64 bytes from 10.21.1.101: icmp_seq=2 ttl=64 time=2.07 ms
unknown option 86
64 bytes from 10.21.1.101: icmp_seq=3 ttl=64 time=1.96 ms
unknown option 86

Both the nc and ping are showing cipso type 1 (only) with doi 101

netlabel_peer_t?
option 86?
```

```bash
[root@netse2 src]# ./getpeercon_server 1030
-> running as unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
-> creating socket ... ok
-> listening on TCP port 1030 ... ok
-> waiting ... connect(10.21.1.100,system_u:object_r:netlabel_peer_t:s0)
-> connection closed
-> waiting ... 
```

```text
nc and getpeercon_server are probably running as unconfined_t due to root
[root@netse1 ~]# id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

What is netlabel_peer_t though?
For cispo, I guess domain (from DOI) isn't copied to ingress traffic.
Only sensitivity and category are set.

Refering to docs, full selinux context is passed for localhost only.
Sensitivity and category are passed by cispo/calipso.
Type context is always netlabel_peer_t.
```

```bash
# netlabel_peer_t might be from unlabeled default fallback selinux context
# No, it's not set and says NO_CONTEXT
netlabelctl unlbl add interface:lo address:127.0.0.1 label:system_u:object_r:netlabel_peer_t:s0
netlabelctl -p unlbl list
```
