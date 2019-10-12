# $OpenBSD$

# Copyright (c) 2019 Alexander Bluhm <bluhm@openbsd.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# test ifconfig address configuration for ethernet

IFCONFIG ?=	${SUDO} ${KTRACE} /sbin/ifconfig

ETHER_IF ?=	vether99
ETHER_ADDR ?=	10.188.254.74
ETHER_NET =	${ETHER_ADDR:C/\.[0-9][0-9]*$//}

CLEANFILES =	ifconfig.out ktrace.out

REGRESS_SETUP =		setup-ether
setup-ether:
	@echo '======== $@ ========'
	${SUDO} /sbin/ifconfig ${ETHER_IF} destroy 2>/dev/null || true
	${SUDO} /sbin/ifconfig ${ETHER_IF} create
	
REGRESS_CLEANUP =	cleanup-ether
cleanup-ether:
	@echo '======== $@ ========'
	${SUDO} /sbin/ifconfig ${ETHER_IF} destroy || true

REGRESS_TARGETS +=	run-ether-addr
run-ether-addr:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_ADDR}
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} ' ifconfig.out

REGRESS_TARGETS +=	run-ether-inet
run-ether-inet:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} inet ${ETHER_ADDR}
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} ' ifconfig.out

REGRESS_TARGETS +=	run-ether-mask
run-ether-mask:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_ADDR} netmask 255.255.255.0
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-prefixlen
run-ether-prefixlen:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_ADDR}/24
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-hexmask
run-ether-hexmask:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_ADDR} netmask 0xffffff00
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-broadcast
run-ether-broadcast:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_ADDR}/24
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} .* broadcast ${ETHER_NET}.255$$' ifconfig.out

REGRESS_TARGETS +=	run-ether-replace
run-ether-replace:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/24
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	! grep 'inet ${ETHER_NET}.1 ' ifconfig.out
	grep 'inet ${ETHER_NET}.2 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-dup
run-ether-dup:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 ' ifconfig.out
	grep -c 'inet ${ETHER_NET}.1 ' ifconfig.out | grep 1

REGRESS_TARGETS +=	run-ether-host
run-ether-host:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/32
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 netmask 0xffffffff$$' ifconfig.out
	grep -c 'inet ${ETHER_NET}.1 ' ifconfig.out | grep 1

REGRESS_TARGETS +=	run-ether-alias
run-ether-alias:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/24 alias
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 ' ifconfig.out
	grep 'inet ${ETHER_NET}.2 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-alias-dup
run-ether-alias-dup:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24 alias
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 ' ifconfig.out
	grep -c 'inet ${ETHER_NET}.1 ' ifconfig.out | grep 1

REGRESS_TARGETS +=	run-ether-replace-first
run-ether-replace-first:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/24 alias
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.3/24
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	! grep 'inet ${ETHER_NET}.1 ' ifconfig.out
	grep 'inet ${ETHER_NET}.2 ' ifconfig.out
	grep 'inet ${ETHER_NET}.3 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-alias-host
run-ether-alias-host:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/32 alias
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 netmask 0xffffffff$$' ifconfig.out
	grep -c 'inet ${ETHER_NET}.1 ' ifconfig.out | grep 1

REGRESS_TARGETS +=	run-ether-change-mask
run-ether-change-mask:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/24 alias
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/32
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 netmask 0xffffffff$$' ifconfig.out
	grep -c 'inet ${ETHER_NET}.1 ' ifconfig.out | grep 1
	grep 'inet ${ETHER_NET}.2 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-change-mask2
run-ether-change-mask2:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/24 alias
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/32
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 ' ifconfig.out
	grep 'inet ${ETHER_NET}.2 netmask 0xffffffff$$' ifconfig.out
	grep -c 'inet ${ETHER_NET}.2 ' ifconfig.out | grep 1

# We add two addresses, replace one, and end up with only one.
# This should be investigated.
REGRESS_EXPECTED_FAILURES +=	run-ether-change-mask2

REGRESS_TARGETS +=	run-ether-alias-mask
run-ether-alias-mask:
	@echo '======== $@ ========'
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.1/24
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/24 alias
	${IFCONFIG} ${ETHER_IF} ${ETHER_NET}.2/32 alias
	/sbin/ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_NET}.1 ' ifconfig.out
	grep 'inet ${ETHER_NET}.2 netmask 0xffffffff$$' ifconfig.out
	grep -c 'inet ${ETHER_NET}.2 ' ifconfig.out | grep 1

REGRESS_ROOT_TARGETS =	${REGRESS_TARGETS}

check-targets:
	# REGRESS_TARGETS must not contain duplicates, prevent copy paste error
	! echo ${REGRESS_TARGETS} | tr ' ' '\n' | sort | uniq -d | grep .

.include <bsd.regress.mk>
