# SPDX-License-Identifier: GPL-2.0-only
################################################################################
#
# r8101 is the Linux device driver released for Realtek Fast Ethernet
# controllers with PCI-Express interface.
#
# Copyright(c) 2024 Realtek Semiconductor Corp. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.
#
# Author:
# Realtek NIC software team <nicfae@realtek.com>
# No. 2, Innovation Road II, Hsinchu Science Park, Hsinchu 300, Taiwan
#
################################################################################

################################################################################
#  This product is covered by one or more of the following patents:
#  US6,570,884, US6,115,776, and US6,327,625.
################################################################################

CONFIG_SOC_LAN = n
CONFIG_ASPM = y
ENABLE_S5WOL = y
ENABLE_S5_KEEP_CURR_MAC = n
ENABLE_EEE = y
ENABLE_S0_MAGIC_PACKET = n
CONFIG_CTAP_SHORT_OFF = n

ifneq ($(KERNELRELEASE),)
	obj-m := r8101.o
	r8101-objs := r8101_n.o rtl_eeprom.o rtltool.o
	EXTRA_CFLAGS += -DCONFIG_R8101_NAPI
	EXTRA_CFLAGS += -DCONFIG_R8101_VLAN
	ifeq ($(CONFIG_SOC_LAN), y)
		EXTRA_CFLAGS += -DCONFIG_SOC_LAN
	endif
	ifeq ($(CONFIG_ASPM), y)
		EXTRA_CFLAGS += -DCONFIG_ASPM
	endif
	ifeq ($(ENABLE_S5WOL), y)
		EXTRA_CFLAGS += -DENABLE_S5WOL
	endif
	ifeq ($(ENABLE_S5_KEEP_CURR_MAC), y)
		EXTRA_CFLAGS += -DENABLE_S5_KEEP_CURR_MAC
	endif
	ifeq ($(ENABLE_EEE), y)
		EXTRA_CFLAGS += -DENABLE_EEE
	endif
	ifeq ($(ENABLE_S0_MAGIC_PACKET), y)
		EXTRA_CFLAGS += -DENABLE_S0_MAGIC_PACKET
	endif
	ifeq ($(CONFIG_CTAP_SHORT_OFF), y)
		EXTRA_CFLAGS += -DCONFIG_CTAP_SHORT_OFF
	endif
else
	BASEDIR := /lib/modules/$(shell uname -r)
	KERNELDIR ?= $(BASEDIR)/build
	PWD :=$(shell pwd)
	DRIVERDIR := $(shell find $(BASEDIR)/kernel/drivers/net/ethernet -name realtek -type d)
	ifeq ($(DRIVERDIR),)
		DRIVERDIR := $(shell find $(BASEDIR)/kernel/drivers/net -name realtek -type d)
	endif
	ifeq ($(DRIVERDIR),)
		DRIVERDIR := $(BASEDIR)/kernel/drivers/net
	endif
	RTKDIR := $(subst $(BASEDIR)/,,$(DRIVERDIR))

	KERNEL_GCC_VERSION := $(shell cat /proc/version | sed -n 's/.*gcc version \([[:digit:]]\.[[:digit:]]\.[[:digit:]]\).*/\1/p')
	CCVERSION = $(shell $(CC) -dumpversion)

	KVER = $(shell uname -r)
	KMAJ = $(shell echo $(KVER) | \
	sed -e 's/^\([0-9][0-9]*\)\.[0-9][0-9]*\.[0-9][0-9]*.*/\1/')
	KMIN = $(shell echo $(KVER) | \
	sed -e 's/^[0-9][0-9]*\.\([0-9][0-9]*\)\.[0-9][0-9]*.*/\1/')
	KREV = $(shell echo $(KVER) | \
	sed -e 's/^[0-9][0-9]*\.[0-9][0-9]*\.\([0-9][0-9]*\).*/\1/')

	kver_ge = $(shell \
	echo test | awk '{if($(KMAJ) < $(1)) {print 0} else { \
	if($(KMAJ) > $(1)) {print 1} else { \
	if($(KMIN) < $(2)) {print 0} else { \
	if($(KMIN) > $(2)) {print 1} else { \
	if($(KREV) < $(3)) {print 0} else { print 1 } \
	}}}}}' \
	)

.PHONY: all
all: print_vars clean modules install

print_vars:
	@echo
	@echo "CC: " $(CC)
	@echo "CCVERSION: " $(CCVERSION)
	@echo "KERNEL_GCC_VERSION: " $(KERNEL_GCC_VERSION)
	@echo "KVER: " $(KVER)
	@echo "KMAJ: " $(KMAJ)
	@echo "KMIN: " $(KMIN)
	@echo "KREV: " $(KREV)
	@echo "BASEDIR: " $(BASEDIR)
	@echo "DRIVERDIR: " $(DRIVERDIR)
	@echo "PWD: " $(PWD)
	@echo "RTKDIR: " $(RTKDIR)
	@echo

.PHONY:modules
modules:
#ifeq ($(call kver_ge,5,0,0),1)
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
#else
#	$(MAKE) -C $(KERNELDIR) SUBDIRS=$(PWD) modules
#endif

.PHONY:clean
clean:
#ifeq ($(call kver_ge,5,0,0),1)
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
#else
#	$(MAKE) -C $(KERNELDIR) SUBDIRS=$(PWD) clean
#endif

.PHONY:install
install:
#ifeq ($(call kver_ge,5,0,0),1)
	$(MAKE) -C $(KERNELDIR) M=$(PWD) INSTALL_MOD_DIR=$(RTKDIR) modules_install
#else
#	$(MAKE) -C $(KERNELDIR) SUBDIRS=$(PWD) INSTALL_MOD_DIR=$(RTKDIR) modules_install
#endif

endif
