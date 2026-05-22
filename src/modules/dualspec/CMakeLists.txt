set(LIBRARY_NAME dualspec)

file(GLOB dualspec_source ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
file(GLOB dualspec_features_source ${CMAKE_CURRENT_SOURCE_DIR}/src/features/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/src/features/*.h)
source_group("dualspec" FILES ${dualspec_source})
source_group("dualspec\\features" FILES ${dualspec_features_source})

set(LIBRARY_SRCS ${dualspec_source} ${dualspec_features_source})

include_directories(${CMAKE_SOURCE_DIR}/src/modules/modules/src)
add_definitions(-DENABLE_MODULES)
add_definitions(-DENABLE_DUALSPEC)

if (${CMAKE_PROJECT_NAME} MATCHES "Classic")
  add_definitions(-DEXPANSION=0)
endif()
if (${CMAKE_PROJECT_NAME} MATCHES "TBC")
  add_definitions(-DEXPANSION=1)
endif()
if (${CMAKE_PROJECT_NAME} MATCHES "WoTLK")
  add_definitions(-DEXPANSION=2)
endif()

add_library(${LIBRARY_NAME} STATIC ${LIBRARY_SRCS})

target_link_libraries(${LIBRARY_NAME}
  modules
  shared
  RecastNavigation::Detour
)

if(UNIX)
  if (NOT (CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR CMAKE_SYSTEM_NAME STREQUAL "NetBSD"))
    target_link_libraries(${LIBRARY_NAME} dl)
  endif()
endif()

set_target_properties(${LIBRARY_NAME} PROPERTIES PROJECT_LABEL "DualSpec")
set_target_properties(${LIBRARY_NAME} PROPERTIES FOLDER "Modules")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/dualspec.conf.dist.in ${CMAKE_CURRENT_BINARY_DIR}/dualspec.conf.dist)
if (NOT CONF_INSTALL_DIR)
  set(CONF_INSTALL_DIR ${CONF_DIR})
endif()
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/dualspec.conf.dist DESTINATION ${CONF_INSTALL_DIR})
