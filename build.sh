#!/usr/bin/env bash
BLOBFS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## Use "export INCLUDE_TESTS=1" to enable building tests

## Build the cpplite lib first
#echo "Building the cpplite lib"
if [ "$1" = "debug" ]
then
#rm -rf cpplite/build.release
#rm -rf build/blobfuse
mkdir cpplite/build.release
cd cpplite/build.release
echo "Building cpplite in Debug mode"
while getopts d:f: option
do
case "${option}"
in
d) distro=${OPTARG}
if [ "$distro" = "rhel7.8" -o "$distro" = "rhel7.5" ]
then
	echo "Linux version rhel 7"
    cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_ADLS=ON -DUSE_OPENSSL=ON
else
    cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_ADLS=ON -DUSE_OPENSSL=OFF
fi
 ;;
f) FORMAT=${OPTARG};;
esac
done
else
mkdir cpplite/build.release
cd cpplite/build.release
# add this temporarily just for testing open ssl
while getopts d:f: option
do
case "${option}"
in
d) distro=${OPTARG}
if [ "$distro" = "rhel7.8" -o "$distro" = "rhel7.5" ]
then
	echo "Linux version rhel 7"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_ADLS=ON -DUSE_OPENSSL=ON
else
    echo "version other than rhel 7"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_ADLS=ON -DUSE_OPENSSL=OFF
fi
 ;;
f) FORMAT=${OPTARG};;
esac
done
#uncomment this after fixing the other problem with rhel7.5 and rhel 7.8.
#cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_ADLS=ON -DUSE_OPENSSL=OFF
fi

cmake --build .
status=$?

if test $status -eq 0
then
	echo "************************ CPPLite build Successful ***************************** "
else
	echo "************************ CPPLite build Failed ***************************** "
	exit $status
fi
cd -

## install pkg-config, cmake, libcurl and libfuse first
## For example, on ubuntu - sudo apt-get install pkg-config libfuse-dev cmake libcurl4-openssl-dev -y
mkdir build
cd build

# Copy the cpplite lib here
#cp ../cpplite/build.release/libazure*.a ./ 

if [ "$1" = "debug" ]
then
	cmake_args='-DCMAKE_BUILD_TYPE=Debug ..'
	if [ -n "${INCLUDE_TESTS}" ]; then
		cmake_args='-DCMAKE_BUILD_TYPE=Debug -DINCLUDE_TESTS=1 ..'
	fi
else
	cmake_args='-DCMAKE_BUILD_TYPE=RelWithDebInfo ..'
	if [ -n "${INCLUDE_TESTS}" ]; then
		cmake_args='-DCMAKE_BUILD_TYPE=RelWithDebInfo -DINCLUDE_TESTS=1 ..'
	fi
fi

while getopts d:f: option
do
case "${option}"
in
d) distro=${OPTARG}
if [ "$distro" = "rhel7.8" -o "$distro" = "rhel7.5" ]
then
	echo "Linux version rhel 7"
    cmake_args="${cmake_args} -DUSE_OPENSSL"
fi
 ;;
f) FORMAT=${OPTARG};;
esac
done

## Use cmake3 if it's available.  If not, then fallback to the default "cmake".  Otherwise, fail.
cmake3 $cmake_args
if [ $? -ne 0 ]
then
    cmake $cmake_args
fi 
if [ $? -ne 0 ]
then
	ERRORCODE=$?
	echo "cmake failed.  Please ensure that cmake version 3.5 or greater is installed and available."
	exit $ERRORCODE
fi
make
