#!/bin/bash

# Alex Bettarini - 15 Mar 2019

export CONFIG_=STEP_
export KCONFIG_CONFIG=steps.conf
kconfig-mconf Kconfig-miele
