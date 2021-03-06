project(qtprotobufgen VERSION ${QT_PROTOBUF_VERSION} LANGUAGES CXX)

set(TARGET ${PROJECT_NAME})
set(TARGET_EXPORT ${TARGET}Targets)
set(TARGET_BINDIR ${CMAKE_INSTALL_BINDIR})

file(GLOB SOURCES main.cpp
    generator.cpp
    classgeneratorbase.cpp
    servergenerator.cpp
    protobufclassgenerator.cpp
    enumsgenerator.cpp
    enumssourcegenerator.cpp
    servicegeneratorbase.cpp
    templates.cpp
    clientgenerator.cpp
    classsourcegeneratorbase.cpp
    protobufsourcegenerator.cpp
    clientsourcegenerator.cpp
    singlefilegenerator.cpp
    generatorbase.cpp
    generatoroptions.cpp)

file(GLOB HEADERS classgeneratorbase.h
    classsourcegeneratorbase.h
    clientgenerator.h
    clientsourcegenerator.h
    generator.h
    enumsgenerator.h
    enumssourcegenerator.h
    protobufclassgenerator.h
    protobufsourcegenerator.h
    servergenerator.h
    servicegeneratorbase.h
    templates.h
    utils.h
    singlefilegenerator.h
    generatorbase.h
    generatoroptions.h)

add_executable(${TARGET} ${SOURCES})

if(DEFINED Protobuf_INCLUDE_DIRS)
    target_include_directories(${TARGET} PUBLIC ${Protobuf_INCLUDE_DIRS})
endif()

target_link_libraries(${TARGET} protobuf::libprotobuf protobuf::libprotoc)

install(TARGETS ${TARGET}
    RUNTIME DESTINATION ${TARGET_BINDIR} COMPONENT lib)
