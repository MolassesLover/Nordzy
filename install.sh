#!/bin/bash

ROOT_UID=0
DEST_DIR=

# Destination directory
# Check root user
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Nordzy
COLOR_VARIANTS=('' '-dark')
THEME_VARIANTS=('' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-turquoise' '-cyan')

# Display ascii art
ascii_art() {
  cat < nordzy-ascii-art.txt
  sleep 2
}

# Show help
usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -t, --theme VARIANT     Specify theme color variant(s) [default|purple|pink|red|orange|yellow|green|turquoise|cyan|all] (Default: blue)
    -c, --color VARIANT     Specify color variant(s) [standard|light|dark] (Default: All variants)s)
    -h, --help              Show help
EOF
}

install() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local color=${4}

  local THEME_DIR=${dest}/${name}${theme}${color}

  # If theme dir exist: remove it
  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  # which theme, in which directory
  echo "Installing '${THEME_DIR}'..."

  # copy files to theme dir
  mkdir -p                                                                             ${THEME_DIR}
  cp -r ${SRC_DIR}/{COPYING,AUTHORS}                                                   ${THEME_DIR}
  cp -r ${SRC_DIR}/src/index.theme                                                     ${THEME_DIR}

  cd ${THEME_DIR}
  sed -i "s/${name}/${name}${theme}${color}/g" index.theme

  # install default theme color
  if [[ ${color} == '' ]]; then
    mkdir -p                                                                               ${THEME_DIR}/status
    cp -r ${SRC_DIR}/src/{actions,animations,apps,categories,devices,emblems,mimes,places} ${THEME_DIR}
    cp -r ${SRC_DIR}/src/status/{16,22,24,32,scalable,symbolic}                            ${THEME_DIR}/status
    cp -r ${SRC_DIR}/links/{actions,apps,categories,devices,emblems,mimes,places,status}   ${THEME_DIR}

    if [[ $DESKTOP_SESSION == '/usr/share/xsessions/budgie-desktop' ]]; then
      cp -r ${SRC_DIR}/src/status/symbolic-budgie/*.svg                                    ${THEME_DIR}/status/symbolic
    fi

    # If another theme color is specified
    if [[ ${theme} != '' ]]; then
      cp -r ${SRC_DIR}/colors/color${theme}/*.svg                                          ${THEME_DIR}/places/scalable
    fi
  fi

  if [[ ${color} == '-dark' ]]; then
    mkdir -p                                                                           ${THEME_DIR}/{apps,categories,emblems,devices,mimes,places,status}

    # Create a copy of some of the icons (mainly symbolic)
    cp -r ${SRC_DIR}/src/actions                                                       ${THEME_DIR}
    cp -r ${SRC_DIR}/src/apps/symbolic                                                 ${THEME_DIR}/apps
    cp -r ${SRC_DIR}/src/categories/symbolic                                           ${THEME_DIR}/categories
    cp -r ${SRC_DIR}/src/emblems/symbolic                                              ${THEME_DIR}/emblems
    cp -r ${SRC_DIR}/src/mimes/symbolic                                                ${THEME_DIR}/mimes
    cp -r ${SRC_DIR}/src/devices/{16,22,24,symbolic}                                   ${THEME_DIR}/devices
    cp -r ${SRC_DIR}/src/places/{16,22,24,symbolic}                                    ${THEME_DIR}/places
    cp -r ${SRC_DIR}/src/status/{16,22,24,symbolic}                                    ${THEME_DIR}/status

    if [[ $DESKTOP_SESSION == '/usr/share/xsessions/budgie-desktop' ]]; then
      cp -r ${SRC_DIR}/src/status/symbolic-budgie/*.svg                                ${THEME_DIR}/status/symbolic
    fi

    # Change icon color for dark theme
    sed -i "s/#2e3440/#d8dee9/g" "${THEME_DIR}"/{actions,devices,places,status}/{16,22,24}/*
    sed -i "s/#2e3440/#d8dee9/g" "${THEME_DIR}"/actions/32/*
    sed -i "s/#2e3440/#d8dee9/g" "${THEME_DIR}"/{actions,apps,categories,emblems,devices,mimes,places}/symbolic/*

    # copy the links for the above icons
    cp -r ${SRC_DIR}/links/actions/{16,22,24,32,symbolic}                              ${THEME_DIR}/actions
    cp -r ${SRC_DIR}/links/devices/{16,22,24,symbolic}                                 ${THEME_DIR}/devices
    cp -r ${SRC_DIR}/links/places/{16,22,24,symbolic}                                  ${THEME_DIR}/places
    cp -r ${SRC_DIR}/links/status/{16,22,24,symbolic}                                  ${THEME_DIR}/status
    cp -r ${SRC_DIR}/links/apps/symbolic                                               ${THEME_DIR}/apps
    cp -r ${SRC_DIR}/links/categories/symbolic                                         ${THEME_DIR}/categories
    cp -r ${SRC_DIR}/links/mimes/symbolic                                              ${THEME_DIR}/mimes

    
    cd ${dest}

    # Make links for the remaining icons that must stay unchanged
    ln -s ../${name}${theme}/animations ${name}${theme}-dark/animations
    ln -s ../../${name}${theme}/categories/32 ${name}${theme}-dark/categories/32
    ln -s ../../${name}${theme}/emblems/16 ${name}${theme}-dark/emblems/16
    ln -s ../../${name}${theme}/emblems/22 ${name}${theme}-dark/emblems/22
    ln -s ../../${name}${theme}/emblems/24 ${name}${theme}-dark/emblems/24
    ln -s ../../${name}${theme}/mimes/16 ${name}${theme}-dark/mimes/16
    ln -s ../../${name}${theme}/mimes/22 ${name}${theme}-dark/mimes/22
    ln -s ../../${name}${theme}/mimes/scalable ${name}${theme}-dark/mimes/scalable
    ln -s ../../${name}${theme}/apps/scalable ${name}${theme}-dark/apps/scalable
    ln -s ../../${name}${theme}/devices/scalable ${name}${theme}-dark/devices/scalable
    ln -s ../../${name}${theme}/places/scalable ${name}${theme}-dark/places/scalable
    ln -s ../../${name}${theme}/status/32 ${name}${theme}-dark/status/32
    ln -s ../../${name}${theme}/status/scalable ${name}${theme}-dark/status/scalable
  fi

  (
    cd ${THEME_DIR}
    ln -sf actions actions@2x
    ln -sf animations animations@2x
    ln -sf apps apps@2x
    ln -sf categories categories@2x
    ln -sf devices devices@2x
    ln -sf emblems emblems@2x
    ln -sf mimes mimes@2x
    ln -sf places places@2x
    ln -sf status status@2x
  )

  gtk-update-icon-cache ${THEME_DIR}
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          turquoise)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          cyan)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
        # echo "Installing '${theme}' folder version..."
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

install_theme() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
    done
  done
}

ascii_art
install_theme
