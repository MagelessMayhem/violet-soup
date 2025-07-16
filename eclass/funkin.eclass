# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: funkin.eclass
# @MAINTAINER:
# Sebastian France <MagelessMayhem@protonmail.com>
# @AUTHOR:
# Sebastian France <MagelessMayhem@protonmail.com>
# @SUPPORTED_EAPIS: 8
# @BLURB: Eclass designed to assist with compiling FNF and FNF mods 
# @DESCRIPTION:
# The Funkin eclass, as its name implies, implements workarounds to assist in compiling Friday Night Funkin'.
# The reason it does this is because of the way the game is built, as you'll see in the eclass implementations.

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ ! ${_FUNKIN_ECLASS} ]]; then
_FUNKIN_ECLASS=1

fi

BDEPEND="dev-lang/haxe-bin"

# @ECLASS_VARIABLE: FUNKIN_LIME_TARGET
# @DESCRIPTION:
# A variable which defines the build target for Lime, the project manager used to build the game.
# Lime uses the value of this variable to pass appropriate compilation instructions to HXCPP.
# Available values are debug and release, which are also defined in the LIME_TARGET USE_EXPAND variable.
# If this variable is left unset by the developer, release will be used.
: "${FUNKIN_LIME_TARGET:=release}"

# @ECLASS_VARIABLE: FUNKIN_OPTIONS
# @DESCRIPTION:
# Added to accompany game version 0.6.4, this is a variable which defines compiler options to pass.
# This variable should be set in the ebuild using FUNKIN_FEATURES USE flags.
# The games-arcade/funkin ebuild demonstrates its usage in the src_compile() phase.
: "${FUNKIN_OPTIONS:=""}"

# @FUNCTION: funkin_src_prepare
# @DESCRIPTION:
# Exported function which runs necessary preparations for building the game in the src_prepare phase.
# The primary duty of this function is to set up compiler flags according to the user's preferences.
# The cross compiler used, HXCPP, stores flags in XML format, so this step is necessary for proper compilation.

funkin_src_prepare() {
	# Check if the current directory contains HXCPP	
	if [[ -d "${S}/.haxelib/hxcpp" ]] ; then
		HXCPP_XML=$(find "${S}/.haxelib/hxcpp" -name common-defines.xml)
		if [[ ! -z "$HXCPP_XML" ]] ; then
			# Use sed magic to add compiler flags to HXCPP's main XML
			# If for whatever reason CFLAGS/CXXFLAGS aren't set, no magic will be used

			ORIGINAL_IFS="${IFS}"
			IFS=" "

			if [[ ! -z "${CFLAGS}" ]] ; then
				read -ra HXCPP_CFLAGS <<< "${CFLAGS}"
				for CFLAG in "${HXCPP_CFLAGS[@]}"; do
					sed -i "2 i \ <cflag value=\""${CFLAG}"\"\/>" ${HXCPP_XML}
				done
			fi
			if [[ ! -z "${CXXFLAGS}" ]] ; then
				read -ra HXCPP_CXXFLAGS <<< "${CXXFLAGS}"
				for CXXFLAG in "${HXCPP_CXXFLAGS[@]}"; do
					sed -i "2 i \ <cppflag value=\""${CXXFLAG}"\"\/>" ${HXCPP_XML}
				done
			fi

			IFS="${ORIGINAL_IFS}"
		else
			die "common-defines.xml was not found..."
		fi
	else
		die "HXCPP not found!"
	fi
}

# @FUNCTION: funkin_src_compile
# @DESCRIPTION: 
# This function builds the game (or mod of the game) whilst setting the value of HXCPP_COMPILE_THREADS.
# The value passed to HXCPP_COMPILE_THREADS is equivalent to -jn in MAKEOPTS (if present), where n is a number.

funkin_src_compile() {

	haxelib list
	# Default value if -jn is not found in the following conditional
	HXCPP_JOBS=1
	pattern="-j([0-9]+)"
	if [[ ${MAKEOPTS} =~ $pattern ]]; then

		HXCPP_JOBS=$(cut -c 3- <<< "${BASH_REMATCH[0]}")

	fi
	if [[ $FUNKIN_LIME_TARGET == "release" ]] ; then
		HXCPP_COMPILE_THREADS=${HXCPP_JOBS} haxelib run lime build linux -v ${FUNKIN_OPTIONS}
	else
		HXCPP_COMPILE_THREADS=${HXCPP_JOBS} haxelib run lime build linux -v -debug ${FUNKIN_OPTIONS}
	fi

}

EXPORT_FUNCTIONS src_prepare src_compile
