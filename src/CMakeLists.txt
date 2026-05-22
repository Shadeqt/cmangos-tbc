#
# This file is part of the CMaNGOS Project. See AUTHORS file for Copyright information
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

if(BUILD_GAME_SERVER OR BUILD_LOGIN_SERVER OR BUILD_EXTRACTORS)
  add_subdirectory(framework)
  add_subdirectory(shared)
endif()

# Playerbots module
if(BUILD_PLAYERBOTS)
  include(FetchContent)

  FetchContent_Declare(
    PlayerBots
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/modules/PlayerBots"
    GIT_REPOSITORY "https://github.com/cmangos/playerbots.git"
    GIT_TAG "master"
  )

  FetchContent_GetProperties(PlayerBots)
  if (NOT playerbots_POPULATED)
    FetchContent_Populate(PlayerBots)
    message(STATUS "Playerbots module source dir: ${playerbots_SOURCE_DIR}")
  else()
    message(STATUS "Playerbots module already populated: ${playerbots_POPULATED}")
  endif()

  add_subdirectory(${playerbots_SOURCE_DIR})

else()
  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/modules/PlayerBots)
    message(STATUS "PlayerBots module exists, but not building. You can remove it manually if you don't need it. (rm -rf ${CMAKE_CURRENT_SOURCE_DIR}/modules/PlayerBots)")

    #file(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/modules/PlayerBots)
  endif()
endif()

# Local modules (sourced from this repository, not from cmangos-modules' modules.conf).
# Must run BEFORE add_subdirectory(game): src/game/CMakeLists.txt does a file(GLOB)
# scan of src/modules/* and calls add_dependencies(game <module>) for every folder
# whose BUILD_MODULE_<NAME> flag is on, which requires the target to already exist.
if(BUILD_MODULES)
  # cmangos-modules base library. Its content was COPYed into src/modules/modules by
  # the top-level CMakeLists from the local sibling working tree. The external-modules
  # loop further down used to add_subdirectory this via the MODULES= entry in
  # modules.conf, but that entry is now filtered out to keep the base library local.
  add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/modules/modules)

  file(GLOB LOCAL_MODULE_DIRS LIST_DIRECTORIES true ${CMAKE_CURRENT_SOURCE_DIR}/modules/*)
  foreach(LOCAL_MODULE_DIR ${LOCAL_MODULE_DIRS})
    if(IS_DIRECTORY ${LOCAL_MODULE_DIR})
      get_filename_component(LOCAL_MODULE_NAME ${LOCAL_MODULE_DIR} NAME)
      string(TOUPPER ${LOCAL_MODULE_NAME} LOCAL_MODULE_UPPER)
      # Skip "modules" (already added above) and anything still tracked in modules.conf.
      if(LOCAL_MODULE_UPPER STREQUAL "MODULES")
        continue()
      endif()
      list(FIND MODULE_NAMES ${LOCAL_MODULE_UPPER} UPSTREAM_INDEX)
      if(UPSTREAM_INDEX EQUAL -1 AND BUILD_MODULE_${LOCAL_MODULE_UPPER})
        message(STATUS "Adding local module: ${LOCAL_MODULE_NAME}")
        add_subdirectory(${LOCAL_MODULE_DIR})
      endif()
    endif()
  endforeach()
endif()

if(BUILD_GAME_SERVER)
  add_subdirectory(game)
  add_subdirectory(mangosd)
endif()

if(BUILD_LOGIN_SERVER)
  add_subdirectory(realmd)
endif()

# Install modules
if(BUILD_MODULES)
  list(LENGTH MODULE_NAMES MODULE_COUNT)
  math(EXPR MODULE_COUNT "${MODULE_COUNT}-1")
  foreach(INDEX RANGE ${MODULE_COUNT})
    list(GET MODULE_NAMES ${INDEX} MODULE_NAME)
    list(GET MODULE_URLS ${INDEX} MODULE_URL)
  
    string(TOLOWER ${MODULE_NAME} LOWER_MODULE_NAME)
    if(BUILD_MODULE_${MODULE_NAME} OR BUILD_${MODULE_NAME})
      include(FetchContent)

      FetchContent_Declare(
        ${LOWER_MODULE_NAME}
		SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/modules/${LOWER_MODULE_NAME}"
        GIT_REPOSITORY "${MODULE_URL}"
        GIT_TAG "main"
      )

	  FetchContent_GetProperties(${LOWER_MODULE_NAME})
      if(NOT ${LOWER_MODULE_NAME}_POPULATED)
        message(STATUS "Fetching ${LOWER_MODULE_NAME} module...")
        FetchContent_Populate(${LOWER_MODULE_NAME})
        message(STATUS "${LOWER_MODULE_NAME} module fetched and populated in ${CMAKE_CURRENT_SOURCE_DIR}/modules/${LOWER_MODULE_NAME}")
      endif()
	
      add_subdirectory(${CMAKE_SOURCE_DIR}/src/modules/${LOWER_MODULE_NAME})
    else()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/modules/${LOWER_MODULE_NAME})
        file(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/modules/${LOWER_MODULE_NAME})
      endif()
    endif()
  endforeach()
endif()