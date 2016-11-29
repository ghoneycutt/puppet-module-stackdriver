# puppet-module-stackdriver

#### Table of Contents

1. [Module Description](#module-description)
2. [Compatibility](#compatibility)
3. [Class Descriptions](#class-descriptions)
    * [stackdriver](#class-stackdriver)

# Module description

Manage Stackdriver. This includes managing the stackdriver-agent and
stackdriver-extractor packages and services along with the sysconfig
file.

To use, simply `include ::stackdriver`.

# Compatibility

This module is built for use with Puppet v3 and Puppet v4 on the
following platforms and supports Ruby versions 1.8.7 and 2.3.1.

 * EL 6

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-stackdriver.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-stackdriver)

# Class Descriptions
## Class `stackdriver`

### Description

Manages Stackdriver.


### Parameters

---
#### manage_repo (type: Boolean)
Determine if yum repo should be managed.

- *Default*: true

---
#### baseurl (type: String)
Value of baseurl attribute for stackdriver repo. If `undef`, defaults to
using
"http://repo.stackdriver.com/repo/el${::operatingsystemmajrelease}/$basearch/".
Only applicable if `manage_repo` is `true`.

- *Default*: undef

---
#### gpgkey (type: String)
Value of gpgkey attribute for stackdriver repo. Only applicable if `manage_repo` is `true`.

- *Default*: 'https://app.stackdriver.com/RPM-GPG-KEY-stackdriver'
