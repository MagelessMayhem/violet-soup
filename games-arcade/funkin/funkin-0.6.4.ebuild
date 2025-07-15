# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit check-reqs desktop funkin xdg-utils

DESCRIPTION="A rhythm game made with HaxeFlixel"
HOMEPAGE="https://github.com/FunkinCrew/Funkin"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

IUSE="
+X
+alsa
+lime_target_release
lime_target_debug
"
REQUIRED_USE="
X
alsa
|| ( lime_target_debug lime_target_release )
lime_target_debug? ( !lime_target_release )
lime_target_release? ( !lime_target_debug )
"

DEPEND="
x11-libs/pixman
x11-libs/libX11
media-libs/alsa-lib
media-libs/harfbuzz
media-libs/freetype
"
RDEPEND="${DEPEND}"
BDEPEND="
dev-lang/haxe
media-video/vlc
"

CHECKREQS_DISK_BUILD="14G"
CHECKREQS_DISK_USR="1.5G"

pkg_setup() {
	check-reqs_pkg_setup
}


