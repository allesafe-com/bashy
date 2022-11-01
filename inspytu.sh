#!/bin/bash
# This script will install specific versions of Python on Ubuntu Linux servers
if [ "$(whoami)" != "root" ]; then
    echo "WARNING: You must run this script as 'root'"
    # This shortcut method will fail if the script file does not have execute permissions
    exec sudo -- "$0" "$@"
fi

inputVersion=$1
if [[ $inputVersion == "" ]]; then
    echo "You must input a supported version (e.g. 2.7.11, 3.5.1)"
    exit 1
fi

exitOnError() {
    error=$1
    lineno=$2
    echo "The previous command resulted in a fatal error: ${error}, line: ${lineno}"
    exit $error
}

trap 'exitOnError ${?} ${LINENO}' ERR

setNameAndURL() {
    pythonName="Python-${inputVersion}"
    pythonURL="https://www.python.org/ftp/python/${inputVersion}/Python-${inputVersion}.tgz"
}

pythonDependencies() {
    /usr/bin/apt-get update -q
    /usr/bin/apt-get install build-essential checkinstall -qqy || exitOnError $?
    /usr/bin/apt-get install libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -qqy
}

installPip() {
    /usr/bin/apt-get install build-essential python-dev python-pip -qqy || exitOnError $?
    /usr/bin/pip install virtualenv || exitOnError $?
}

download() {
    cd /usr/src
    /usr/bin/curl ${pythonURL} -O -f || exitOnError $?
    /bin/tar xzf ${pythonName}.tgz || exitOnError $?
}

makePython() {
    cd /usr/src/${pythonName}
    ./configure
    make
    make install
}

main() {
    pythonDependencies
    setNameAndURL
    download
    makePython
    installPip
    exit 0
}

main
