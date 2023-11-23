# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils

# Note: This pulls from my fork of the game

DESCRIPTION="A rhythm game made with HaxeFlixel"
HOMEPAGE="https://github.com/FunkinCrew/Funkin https://ninja-muffin24.itch.io/funkin"
SRC_URI="
	https://github.com/MagelessMayhem/Funkin/releases/download/${PV}/funkin-bin.tar.gz -> ${P}.tar.gz
	utau? ( https://github.com/MagelessMayhem/Funkin/releases/download/v0.2.7.1u/utau-covers.tar.gz )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+X utau"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	# Copy the UTAU covers to the game's files if the USE flag is enabled, otherwise do nothing here
	
	if use utau; then
		cp -r ${WORKDIR}/assets/songs ${WORKDIR}/export/release/linux/bin/assets
	fi
}

src_install() {
	keepdir /usr/share/games/Funkin
	insinto /usr/share/games/Funkin
	exeinto /usr/share/games/Funkin/bin
	doins -r ${WORKDIR}/export/release/linux/bin
	doexe ${WORKDIR}/export/release/linux/bin/Funkin
	# This part is necessary because the game cannot access its assets if it is run outside of its home directory
	echo "#!/bin/bash\n( cd /usr/share/games/Funkin/bin; ./Funkin )" > ${WORKDIR}/funkin
	dobin ${WORKDIR}/funkin
	make_desktop_entry /usr/bin/funkin "Friday Night Funkin'"
}
pkg_postinst() {
	xdg_update_desktop_database
}
pkg_postrm() {
	xdg_update_desktop_database
}

