find_package(gRPC CONFIG QUIET)
if(NOT gRPC_FOUND)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(FIND_LIBRARY_USE_LIB64_PATHS TRUE)
        set(FIND_LIBRARY_USE_LIBX32_PATHS FALSE)
        set(FIND_LIBRARY_USE_LIB32_PATHS FALSE)
    else()
        set(FIND_LIBRARY_USE_LIBX32_PATHS TRUE)
        set(FIND_LIBRARY_USE_LIB32_PATHS TRUE)
        set(FIND_LIBRARY_USE_LIB64_PATHS FALSE)
    endif()

    find_program(gRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
    if(NOT TARGET gRPC::grpc_cpp_plugin AND NOT gRPC_CPP_PLUGIN_EXECUTABLE STREQUAL gRPC_CPP_PLUGIN_EXECUTABLE-NOTFOUND)
        add_executable(gRPC::grpc_cpp_plugin IMPORTED)
        set_target_properties(gRPC::grpc_cpp_plugin PROPERTIES IMPORTED_LOCATION ${gRPC_CPP_PLUGIN_EXECUTABLE})
    endif()

    find_library(gRPC_LIBRARY grpc)
    if(NOT TARGET gRPC::grpc AND NOT gRPC_LIBRARY STREQUAL gRPC_LIBRARY-NOTFOUND)
        add_library(gRPC::grpc SHARED IMPORTED)
        set_target_properties(gRPC::grpc PROPERTIES IMPORTED_LOCATION ${gRPC_LIBRARY})
    endif()

    find_library(gRPC_CPP_LIBRARY grpc++)
    if(NOT TARGET gRPC::grpc++ AND NOT gRPC_CPP_LIBRARY STREQUAL gRPC_LIBRARY-NOTFOUND)
        add_library(gRPC::grpc++ SHARED IMPORTED)
        set_target_properties(gRPC::grpc++ PROPERTIES IMPORTED_LOCATION ${gRPC_CPP_LIBRARY} INTERFACE_LINK_LIBRARIES protobuf::libprotobuf)
    endif()

    unset(gRPC_FOUND)
    if(TARGET gRPC::grpc++ AND TARGET gRPC::grpc AND TARGET gRPC::grpc_cpp_plugin)
#        message(STATUS "Found gRPC")
        set(gRPC_FOUND TRUE)
    else()
        unset(gRPC_LIBRARY)
        unset(gRPC_CPP_PLUGIN_EXECUTABLE)
        unset(gRPC_CPP_LIBRARY)
    endif()
endif()
