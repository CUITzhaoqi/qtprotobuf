set(TARGET QtProtobuf)
set(TARGET_STATIC ${TARGET}Static)
set(TARGET_EXPORT ${TARGET}Targets)
set(TARGET_CONFIG ${TARGET}Config)

set(TARGET_INCLUDE_DIR ${CMAKE_INSTALL_INCLUDEDIR}/${TARGET})
set(TARGET_LIB_DIR ${CMAKE_INSTALL_LIBDIR})
set(TARGET_CMAKE_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
set(TARGET_BINDIR ${CMAKE_INSTALL_BINDIR})

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Qml REQUIRED)
find_package(microjson CONFIG REQUIRED)

include(${QT_PROTOBUF_CMAKE_DIR}/Coverage.cmake)
include(${QT_PROTOBUF_CMAKE_DIR}/GenerateQtHeaders.cmake)
include(${QT_PROTOBUF_CMAKE_DIR}/QtProtobufCommon.cmake)

file(GLOB SOURCES
    qtprotobuf.cpp
    qtprotobuflogging.cpp
    qprotobufserializerregistry.cpp
    qabstractprotobufserializer.cpp
    qprotobufjsonserializer.cpp
    qprotobufserializer.cpp
    qprotobufmetaproperty.cpp
    qprotobufmetaobject.cpp)

file(GLOB HEADERS
    qtprotobufglobal.h
    qtprotobuftypes.h
    qtprotobuflogging.h
    qprotobufobject.h
    qprotobufserializerregistry_p.h
    qqmllistpropertyconstructor.h
    qabstractprotobufserializer.h
    qabstractprotobufserializer_p.h
    qprotobufserializer.h
    qprotobufserializer_p.h
    qprotobufjsonserializer.h
    qprotobufselfcheckiterator.h
    qprotobufmetaproperty.h
    qprotobufmetaobject.h
    qprotobufserializationplugininterface.h)

file(GLOB PUBLIC_HEADER
    qtprotobufglobal.h
    qtprotobuftypes.h
    qtprotobuflogging.h
    qprotobufobject.h
    qqmllistpropertyconstructor.h
    qabstractprotobufserializer.h
    qabstractprotobufserializer_p.h
    qprotobufserializer.h
    qprotobufjsonserializer.h
    qprotobufselfcheckiterator.h
    qprotobufmetaproperty.h
    qprotobufmetaobject.h
    qprotobufserializationplugininterface.h)

protobuf_generate_qt_headers(PUBLIC_HEADER ${PUBLIC_HEADER} COMPONENT ${TARGET})

if(QT_PROTOBUF_STATIC)
    if(WIN32)
        message(WARNING "Static version of QtProtobuf is not fully tested on Win32 platforms")
    endif()
    add_library(${TARGET} STATIC ${SOURCES})
    target_compile_definitions(${TARGET} PRIVATE QT_PROTOBUF_STATIC)
    set(QT_PROTOBUF_EXTRA_COMPILE_DIFINITIONS QT_PROTOBUF_STATIC)
else()
    add_library(${TARGET} SHARED ${SOURCES})
endif()

if(NOT DEFINED QT_QMAKE_EXECUTABLE)
    find_program(QT_QMAKE_EXECUTABLE "qmake")
    if(QT_QMAKE_EXECUTABLE STREQUAL QT_QMAKE_EXECUTABLE-NOTFOUND)
        message(FATAL_ERROR "Could not find qmake executable")
    endif()
endif()

extract_qt_variable(QT_INSTALL_PLUGINS)
extract_qt_variable(QT_HOST_DATA)

set_target_properties(${TARGET} PROPERTIES QT_PROTOBUF_PLUGIN_PATH "${QT_INSTALL_PLUGINS}/protobuf")
target_compile_definitions(${TARGET} PUBLIC QT_PROTOBUF_PLUGIN_PATH="${QT_INSTALL_PLUGINS}/protobuf")

target_compile_definitions(${TARGET} PRIVATE QT_BUILD_PROTOBUF_LIB PUBLIC QT_PROTOBUF_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
    QT_PROTOBUF_VERSION_MINOR=${PROJECT_VERSION_MINOR})

set_target_properties(${TARGET} PROPERTIES VERSION ${PROJECT_VERSION} PUBLIC_HEADER "${PUBLIC_HEADER};${GENERATED_PUBLIC_HEADER}" OUTPUT_NAME ${TARGET})
target_include_directories(${TARGET} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${QT_PROTOBUF_BINARY_DIR}/include/${TARGET}>
    $<INSTALL_INTERFACE:${TARGET_INCLUDE_DIR}>
)

target_compile_features(${TARGET} PUBLIC cxx_std_14
                                         cxx_auto_type
                                         cxx_decltype
                                         cxx_final
                                         cxx_override
                                         cxx_nullptr
                                         cxx_lambdas
                                         cxx_func_identifier)

target_link_libraries(${TARGET} PUBLIC Qt5::Core Qt5::Qml PRIVATE microjson)

add_library(${QT_PROTOBUF_PROJECT}::${TARGET} ALIAS ${TARGET})

install(TARGETS ${TARGET}
    EXPORT ${TARGET_EXPORT} COMPONENT dev
    ARCHIVE DESTINATION ${TARGET_LIB_DIR} COMPONENT lib
    PUBLIC_HEADER DESTINATION ${TARGET_INCLUDE_DIR} COMPONENT dev
    LIBRARY DESTINATION ${TARGET_LIB_DIR} COMPONENT lib
    RUNTIME DESTINATION ${TARGET_BINDIR} COMPONENT lib)

install(EXPORT ${TARGET_EXPORT} NAMESPACE ${QT_PROTOBUF_PROJECT}:: FILE ${TARGET_EXPORT}.cmake DESTINATION ${TARGET_CMAKE_DIR} COMPONENT dev)

include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${TARGET_CONFIG}.cmake.in" "${QT_PROTOBUF_BINARY_DIR}/${TARGET_CONFIG}.cmake"
    INSTALL_DESTINATION "${TARGET_CMAKE_DIR}")

install(FILES "${QT_PROTOBUF_BINARY_DIR}/${TARGET_CONFIG}.cmake" DESTINATION "${TARGET_CMAKE_DIR}" COMPONENT dev)

export(TARGETS ${TARGET} NAMESPACE ${QT_PROTOBUF_PROJECT}:: FILE ${TARGET_EXPORT}.cmake)

configure_file("${QT_PROTOBUF_CMAKE_DIR}/QtProtobufGen.cmake" "${QT_PROTOBUF_BINARY_DIR}/QtProtobufGen.cmake" COPYONLY)
install(FILES "${QT_PROTOBUF_BINARY_DIR}/QtProtobufGen.cmake" DESTINATION "${TARGET_CMAKE_DIR}" COMPONENT dev)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/parsemessages.go" "${QT_PROTOBUF_BINARY_DIR}/parsemessages.go" COPYONLY)
install(FILES "${QT_PROTOBUF_BINARY_DIR}/parsemessages.go" DESTINATION "${TARGET_CMAKE_DIR}" COMPONENT dev)

configure_file("${QT_PROTOBUF_CMAKE_DIR}/ProtobufLookup.cmake" "${QT_PROTOBUF_BINARY_DIR}/ProtobufLookup.cmake" COPYONLY)
install(FILES "${QT_PROTOBUF_BINARY_DIR}/ProtobufLookup.cmake" DESTINATION "${TARGET_CMAKE_DIR}" COMPONENT dev)

if(QT_PROTOBUF_STATIC) #extra config for .pri file in case if static build enabled
    set(QT_PROTOBUF_EXTRA_CONFIG "staticlib")
endif()
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/qt_lib_protobuf.pri.in" "${QT_PROTOBUF_BINARY_DIR}/qt_lib_protobuf.pri" @ONLY)
install(FILES "${QT_PROTOBUF_BINARY_DIR}/qt_lib_protobuf.pri" DESTINATION "${QT_HOST_DATA}/mkspecs/modules" COMPONENT dev)

add_subdirectory("quick")

add_coverage_target(TARGET ${TARGET})
