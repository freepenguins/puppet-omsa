# puppet-omsa ![License badge][license-img]

1. [Overview](#overview)
2. [Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [Development](#development)
7. [Miscellaneous](#miscellaneous)

## Overview

OpenManage, a  Dell, Inc. product, consists  of a number of  network management
and systems management applications. Although  the name sounds like open source
software, it is a closed source and commercial software product.

[linux.dell.com](https://linux.dell.com/repo/hardware/)

## Description

This module enables you to install, deploy, and configure Dell OMSA.

## Setup

Copy this module in your modules folder without *puppet-* in the name.

or

```bash
puppet module install vpgrp-omsa
```

## Usage

```puppet
class { 'omsa':
  package => true,
  service => true,
}
```

## Limitations

So far, this is compatible with Debian, RedHat, and other derivatives.

## Development

Please read carefully CONTRIBUTING.md before making a merge request.

## Miscellaneous

```
    ╚⊙ ⊙╝
  ╚═(███)═╝
 ╚═(███)═╝
╚═(███)═╝
 ╚═(███)═╝
  ╚═(███)═╝
   ╚═(███)═╝
```

[license-img]: https://img.shields.io/badge/license-Apache-blue.svg
