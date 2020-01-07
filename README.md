# QtProtobuf

gRPC and Protobuf generator and bindings for Qt framework

> see [Protobuf](https://developers.google.com/protocol-buffers) and [gRPC](https://grpc.io/) for more information

## [API Reference](https://semlanik.github.io/qtprotobuf)

![](https://github.com/semlanik/qtprotobuf/workflows/Test%20Verification/badge.svg?branch=master)

## Linux Build
### Prerequesties
Check installation of following packages in your system:
- protobuf 3.6.0 or higher
- grpc 1.15.0 or higher
- golang 1.10 or higher (Mandatory dependency for any type of build)

**Note:** Older versions could be supported as well but not officially tested.

#### For Ubuntu
Install GRPC packages in system:

```bash
sudo apt-get install libgrpc++-dev protobuf-compiler-grpc libgrpc++1 libgrpc-dev libgrpc6
```
#### All-in-one build
If required versions of libraries are not found in your system, you may use all-in-one build procedure for prerequesties

Update submodules to fetch 3rdparty dependencies:

```bash
git submodule update --init --recursive
```
### Build
```bash
mkdir build
cd build

#In case Qt installed in system, use:
cmake ..

#In case you have Qt installed from qt installer, use:
cmake .. -DCMAKE_PREFIX_PATH="<path/to/qt/installation>/Qt<qt_version>/<qt_version>/gcc_64/lib/cmake"

cmake --build . [--config <RELEASE|DEBUG>] -- -j<N>
```

## Windows Build
### Prerequesties

Download and install:

- Qt 5.12.3 or higher [1](https://download.qt.io/official_releases/qt/)
- cmake-3.1 or higher [2](https://cmake.org/download/)
- Strawberry perl 5.28 [3](http://strawberryperl.com/)
- GoLang 1.10 or higher [4](https://golang.org/dl/)
- Yasm 1.3 or higher [5](http://yasm.tortall.net/Download.html)
- Actual Visual Studio Compiler with cmake support that required by Qt [6](https://visualstudio.microsoft.com/downloads/)

**Note:** All applications should be in PATH

Update submodules to fetch 3rdparty dependencies:

```bash
git submodule update --init --recursive
```

### Build
Open Qt MSVC command line and follow steps:

```bash
"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" <x86|x64>
cd <directory with qtprotobuf project>
mkdir build
cd build
cmake ..
cmake --build . [--config <RELEASE|DEBUG>] -- /m:<N>
```

## Usage

### Direct usage of generator

```bash
protoc --plugin=protoc-gen-qtprotobuf=<path/to/bin>/qtprotobufgen --qtprotobuf_out=<output_dir> <protofile>.proto [--qtprotobuf_opt=out=<output_dir>]
```

### Integration with project

You can integrate QtProtobuf as submodule in your project or as installed in system package. Add following line in your project CMakeLists.txt:

```cmake
...
find_package(QtProtobufProject CONFIG REQUIRED COMPONENTS QtProtobuf QtGrpc)
file(GLOB PROTO_FILES ABSOLUTE ${CMAKE_CURRENT_SOURCE_DIR}/path/to/protofile1.proto
                               ${CMAKE_CURRENT_SOURCE_DIR}/path/to/protofile2.proto
                               ...
                               ${CMAKE_CURRENT_SOURCE_DIR}/path/to/protofileN.proto)
# Function below generates source files for specified PROTO_FILES,
# writes result to STATIC library target and saves its name to 
# ${QtProtobuf_GENERATED} variable
generate_qtprotobuf(TARGET MyTarget
    OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated
    PROTO_FILES ${PROTO_FILES})
add_executable(MyTarget main.cpp) # Add your target here
target_link_libraries(MyTarget ${QtProtobuf_GENERATED})

```

**Optional:**

You also may pre-specify expected generated headers to prevent dummy-parser mistakes

```cmake
...
set(GENERATED_HEADERS
    # List of artifacts expected after qtprotobufgen job done.
    # Usually it's full list of messages in all packages with .h header suffix
    ...
    )
...
generate_qtprotobuf(TARGET MyTarget
    OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated
    PROTO_FILES ${PROTO_FILES}
    GENERATED_HEADERS ${GENERATED_HEADERS})
...
```

#### Usage

To enable QtProtobuf project you need to register protobuf types. It's good practice to make it in 'main' function.

```cpp
...
#include <QtProtobufTypes>
...
int main(int argc, char *argv[])
{
    QtProtobuf::qRegisterProtobufTypes();
    ... //Qt application initialization and run
}
```

**For each generated class you also need to call 'qRegisterProtobufType&lt;GeneratedClassName&gt;' to enable serialization and QML support**

**Other option is to include common "qtprotobuf_global.qpb.h" file and call apptopriate qRegisterProtobufTypes() method for you package**

### Code exceptions

If any prohibited Qt/QML keyword is used as field name, generator appends '*Proto*' suffix to generated filed name. It's required to omit overloading for example QML reserved names like '*id*' or '*objectName*'.

E.g. for message:
```
message MessageReserved {
    sint32 import = 1;
    sint32 property = 2;
    sint32 id = 3;
}
```

Following properties will be generated:
```cpp
...
    Q_PROPERTY(QtProtobuf::sint32 importProto READ importProto WRITE setImport NOTIFY importProtoChanged)
    Q_PROPERTY(QtProtobuf::sint32 propertyProto READ propertyProto WRITE setProperty NOTIFY propertyProtoChanged)
    Q_PROPERTY(QtProtobuf::sint32 idProto READ idProto WRITE setId NOTIFY idProtoChanged)
...

```

**Note:** List of exceptions might be extended in future releases.

## CMake functions reference

### generate_qtprotobuf

generate_qtprotobuf is cmake helper function that automatically generates STATIC library target from your .proto files

Due to cmake restrictions it's required to specify resulting artifacts manually as list of header files expected after generator job finished.

**Parameters:**

*TARGET* - name of you target that will be base for generated target name.

*OUT_DIR* - output directory that will contain generated artifacts. Usually subfolder in build directory should be used.

*GENERATED_HEADERS* - List of header files expected after generator job finished.

*EXCLUDE_HEADERS* - List of header files to be excluded from pre-parsed list of expected header files (e.g. nested messages that are not supported by QtProtobuf generator).

*PROTO_FILES* - List of .proto files that will be used in generation procedure.

*MULTI* - Enables/disables multi-files generation mode. In case if this property is set to TRUE generator will create pair of header/source files for each message.

**Note:** multi-files generation mode is defined as deprecated by QtProtobuf team, and might have poor support in future.

*QML* - Enables/disables QML code generation in protobuf classes. If set to TRUE qml related code for lists and qml registration to be generated.

**Outcome:**

*QtProtobuf_GENERATED* - variable that will contain generated STATIC library target name.

### qtprotobuf_link_archive

qtprotobuf_link_archive - is cmake helper function that links whole archive to specified target. It might be used in case you know that all symbols from generated static library target must be present in you binary. E.g. if you deliver shared library with generated code to end-point consumer. It takes two arguments as input TARGET and GENERATED_TARGET, without variable names specification.

**Paramters**

*TARGET* - target generated code to be linked to.

*GENERATED_TARGET* - generated code static library target.

### Usefull definitions

*QTPROTOBUF_MAKE_COVERAGE* - if **TRUE/ON**, QtProtobuf will be built with gcov intergration, to collect code coverage reports(usefull for developers). **FALSE** by default

*QTPROTOBUF_MAKE_TESTS* - if **TRUE/ON**, tests for QtProtobuf will be built. **TRUE** by default

*QTPROTOBUF_MAKE_EXAMPLES* - if **TRUE/ON**, built-in examples will be built. **TRUE** by default

*QTPROTOBUF_EXECUTABLE* - contains full path to QtProtobuf generator add_executable

### Windows symbol exports

In case if you need to use generated classes as part of shared library, it's required to [export symbols of generated classes](https://docs.microsoft.com/en-us/cpp/cpp/dllexport-dllimport?view=vs-2019).

QtProtobuf has specific macro to define symbol export/imports. By default all symbols are not exported. To export generated symbols add QT_GENERATED_LIB compiler definition.

E.g.:

```cmake
...
add_library(MyTarget mylib.cpp)
target_compile_definitions(MyTarget PRIVATE QT_GENERATED_LIB)
qtprotobuf_link_archive(MyTarget ${QtProtobuf_GENERATED})
...
```

## Limitations

- QtProtobuf doesn't support nested messages, due to Qt Q_OBJECT limitations.
- QtProtobuf doesn't fully support multi-file generation

## Running tests
```bash
cd <build directory>
ctest
```
## Documentation generation

Project uses doxygen for documentation generation.

#### For Windows additionally install:
* [doxygen](http://www.doxygen.nl/download.html)
* [graphviz](https://graphviz.gitlab.io/_pages/Download/Download_windows.html)


You can generate documentation:

```bash
mkdir build
cd build
cmake ..
cmake --build . --target doc
```
