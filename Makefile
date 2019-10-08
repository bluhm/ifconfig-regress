# $OpenBSD$

# test ifconfig address configuration

ETHER_IF ?=	vether99
ETHER_ADDR ?=	10.188.255.74

REGRESS_SETUP =		setup-ether
setup-ether:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} destroy 2>/dev/null || true
	${SUDO} ifconfig ${ETHER_IF} create
	
REGRESS_CLEANUP =	cleanup-ether
cleanup-ether:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} destroy || true

REGRESS_TARGETS +=	run-ifconfig-addr
run-ifconfig-addr:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR}
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} ' ifconfig.out

REGRESS_TARGETS +=	run-ifconfig-inet
run-ifconfig-inet:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} inet ${ETHER_ADDR}
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} ' ifconfig.out

REGRESS_TARGETS +=	run-ifconfig-mask
run-ifconfig-mask:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR} netmask 255.255.255.0
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ifconfig-prefixlen
run-ifconfig-prefixlen:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR}/24
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

REGRESS_TARGETS +=	run-ifconfig-hexmask
run-ifconfig-hexmask:
	@echo '======== $@ ========'
	${SUDO} ifconfig ${ETHER_IF} ${ETHER_ADDR} netmask 0xffffff00
	ifconfig ${ETHER_IF} >ifconfig.out
	grep 'inet ${ETHER_ADDR} netmask 0xffffff00 ' ifconfig.out

.include <bsd.regress.mk>
