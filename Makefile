# $OpenBSD$

# test ifconfig address configuration

ETHER_IF ?=	vether99
ETHER_ADDR ?=	10.188.254.74
ETHER_NET =	${ETHER_ADDR:C/\.[0-9][0-9]*$//}

CLEANFILES =	ifconfig.out

REGRESS_SETUP =		setup-ether
setup-ether:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} destroy 2>/dev/null || true
	${SUDO} ifconfig ${ETHER_IF} create
	
REGRESS_CLEANUP =	cleanup-ether
cleanup-ether:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} destroy || true

REGRESS_TARGETS +=	run-ether-addr
run-ether-addr:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR}
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} ' ifconfig.out

REGRESS_TARGETS +=	run-ether-inet
run-ether-inet:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} inet ${ETHER_ADDR}
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} ' ifconfig.out

REGRESS_TARGETS +=	run-ether-mask
run-ether-mask:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR} netmask 255.255.255.0
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-prefixlen
run-ether-prefixlen:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR}/24
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-hexmask
run-ether-hexmask:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR} netmask 0xffffff00
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ether-broadcast
run-ether-broadcast:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR}/24
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} .* broadcast ${ETHER_NET}.255$$' ifconfig.out

REGRESS_TARGETS +=	run-ether-broadcast-set
run-ether-broadcast-set:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR}/24 broadcast ${ETHER_NET}.128
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} .* broadcast ${ETHER_NET}.128$$' ifconfig.out

REGRESS_ROOT_TARGETS =	${REGRESS_TARGETS}

check-targets:
	# REGRESS_TARGETS must not contain duplicates, prevent copy paste error
	! echo ${REGRESS_TARGETS} | tr ' ' '\n' | sort | uniq -d | grep .

.include <bsd.regress.mk>
