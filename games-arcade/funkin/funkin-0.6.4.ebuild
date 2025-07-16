# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit check-reqs desktop funkin unpacker xdg-utils

DESCRIPTION="A rhythm game made with HaxeFlixel"
HOMEPAGE="https://github.com/FunkinCrew/Funkin"
SRC_URI="
https://github.com/MagelessMayhem/Funkin/releases/download/v0.6.4-vf/funkin-VF_source.7z
https://github.com/MagelessMayhem/Funkin/releases/download/v0.6.4-vf/funkin-VF_haxelib_other.7z
https://github.com/MagelessMayhem/Funkin/releases/download/v0.6.4-vf/funkin-VF_haxelib_lime.7z
"
S="${WORKDIR}/Funkin"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

IUSE="
+X
+alsa
+lime_target_release
lime_target_debug
funkin_features_github_build
funkin_features_polymod_mods
funkin_features_discord_rpc
+funkin_features_video_playback
funkin_features_chart_editor
+funkin_features_screenshots
funkin_features_stage_editor_experimental
funkin_features_ghost_tapping_experimental
"
REQUIRED_USE="
X
alsa
|| ( lime_target_debug lime_target_release )
lime_target_debug? ( !lime_target_release )
lime_target_release? ( !lime_target_debug )
funkin_features_github_build? ( lime_target_debug )
funkin_features_chart_editor? ( lime_target_debug )
"

DEPEND="
x11-libs/pixman
x11-libs/libX11
media-libs/alsa-lib
media-libs/harfbuzz
media-libs/freetype
media-libs/libvorbis
media-libs/libjpeg-turbo
media-libs/openal
"
RDEPEND="${DEPEND}"
BDEPEND="
dev-lang/haxe
app-arch/p7zip
funkin_features_video_playback? ( media-video/vlc )
"

CHECKREQS_DISK_BUILD="14G"
CHECKREQS_DISK_USR="1.5G"

pkg_setup() {
	check-reqs_pkg_setup
}

src_unpack() {
	# These need to be unpacked in order

	unpack funkin-VF_source.7z
	unpack funkin-VF_haxelib_other.7z
	unpack funkin-VF_haxelib_lime.7z
}

src_prepare() {
	eapply_user

	# Since the extracted archives already provide a Haxelib repository, setup Haxelib to use that repository

	haxelib setup ${S}/.haxelib

	funkin_src_prepare
}

src_compile() {
	# The most complex function in the entire ebuild (lol)
	# To account for the FUNKIN_FEATURES USE flags, compiler options need to be added
	# Technically spaghetti code but there is unfortunately no better way to approach this

	if use funkin_features_github_build; then
		FUNKIN_OPTIONS+="-DGITHUB_BUILD "
	fi

	if use funkin_features_polymod_mods; then
		FUNKIN_OPTIONS+="-DFEATURE_POLYMOD_MODS "
	else
		FUNKIN_OPTIONS+="-DNO_FEATURE_POLYMOD_MODS "
	fi

	if use funkin_features_discord_rpc; then
		FUNKIN_OPTIONS+="-DFEATURE_DISCORD_RPC "
	else
		FUNKIN_OPTIONS+="-DNO_FEATURE_DISCORD_RPC "
	fi

	# This is usually enabled since it's a default USE flag
	if use funkin_features_video_playback; then
		FUNKIN_OPTIONS+="-DFEATURE_VIDEO_PLAYBACK "
	else
		FUNKIN_OPTIONS+="-DNO_FEATURE_VIDEO_PLAYBACK "
	fi

	if use funkin_features_chart_editor; then
		FUNKIN_OPTIONS+="-DFEATURE_CHART_EDITOR "
	else
		FUNKIN_OPTIONS+="-DNO_FEATURE_CHART_EDITOR "
	fi

	# Also enabled by default
	if use funkin_features_screenshots; then
		FUNKIN_OPTIONS+="-DFEATURE_SCREENSHOTS "
	else
		FUNKIN_OPTIONS+="-DNO_FEATURE_SCREENSHOTS "
	fi

	# These next two are experimental features that by default are not used for building the game
	# They can however be enabled via the appropriate USE flags at the user's request
	# Keep in mind I am not responsible for if these cause instability!

	if use funkin_features_stage_editor_experimental; then
		FUNKIN_OPTIONS+="-DFEATURE_STAGE_EDITOR "
	fi
	if use funkin_features_ghost_tapping_experimental; then
		FUNKIN_OPTIONS+="-DFEATURE_GHOST_TAPPING "
	fi

	# Finally start the compilation process
	if use lime_target_debug; then
		FUNKIN_LIME_TARGET="debug"
	fi

	funkin_src_compile
}
src_install() {
	keepdir "/usr/share/games/Funkin"
	insinto "/usr/share/games/Funkin"
	exeinto "/usr/share/games/Funkin/bin"
	if use lime-debug; then
		doins -r "${S}/export/debug/linux/bin"
		doexe "${S}/export/debug/linux/bin/Funkin"
	else
		doins -r "${S}/export/release/linux/bin"
		doexe "${S}/export/release/linux/bin/Funkin"
	fi
	echo '(cd /usr/share/games/Funkin/bin; ./Funkin)' > "${WORKDIR}/funkin"
	dobin "${WORKDIR}/funkin"
	newicon -s 32 "${S}/art/icon32.png" "Funkin32.png"
	newicon -s 16 "${S}/art/icon16.png" "Funkin16.png"
	newicon -s 64 "${S}/art/icon64.png" "Funkin64.png"
	make_desktop_entry '/usr/bin/funkin' "Friday Night Funkin'" '/usr/share/icons/hicolor/64x64/apps/Funkin64.png' 'Game'
}
pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	elog "Friday Night Funkin' can be run in one of two ways:"
	elog
	elog "- Simply running \"funkin\" in your terminal, or"
	elog "- Running the desktop file in your desktop's menu."
}
pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	elog "Any save data stored on the disk has not been removed.\n\nThis save data should be in ~/.local/, and you may wipe it if you wish."
}
