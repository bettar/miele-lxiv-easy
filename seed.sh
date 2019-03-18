#!/bin/bash

# Alex Bettarini - 17 Mar 2019

export CONFIG_=CONFIG_
export KCONFIG_CONFIG=seed.conf
kconfig-mconf Kconfig-seed
