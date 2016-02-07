#!/bin/bash


##
# Default config values
declare readonly DEFAULT_AZKABAN_USER="azkaban"
declare readonly DEFAULT_AZKABAN_GROUP="azkaban"
declare readonly DEFAULT_AZKABAN_HOME="/opt/azkaban-solo"
declare readonly DEFAULT_AZKABAN_OPTS="-Xmx3G"
declare readonly DEFAULT_AZKABAN_TMP="/tmp"
declare readonly DEFAULT_AZKABAN_EXECUTOR_PORT="12321"


##
# Setting config values, or its defaults
AZKABAN_USER=${AZKABAN_USER:-${DEFAULT_AZKABAN_USER}}
AZKABAN_GROUP=${AZKABAN_GROUP:-${DEFAULT_AZKABAN_GROUP}}
AZKABAN_HOME=${AZKABAN_HOME:-${DEFAULT_AZKABAN_HOME}}
AZKABAN_OPTS=${AZKABAN_OPTS:-${DEFAULT_AZKABAN_OPTS}}
AZKABAN_TMP=${AZKABAN_TMP:-${DEFAULT_AZKABAN_TMP}}
AZKABAN_EXECUTOR_PORT=${AZKABAN_EXECUTOR_PORT:-${DEFAULT_AZKABAN_EXECUTOR_PORT}}


##
# Global variables
AZKABAN_PROCESS_PID=""


##
# Console
_console( ) {

  local message="${1}"

  [[ -z "${message}" ]] && echo -e "${message}"
}


##
# Exit from the script
_die( ) {

  local message="${1:-''}"
  local error_code=${2:-0}

  _console "${message}"
  exit ${error_code}
}


##
# Gets the PID of the process
_get_process_pid( ) {
  
  AZKABAN_PROCESS_PID=$(ps -ef | grep -v 'grep' | grep '__AZKABAN_SOLO__' | awk '{ print $2 }')
}

##
# Checks if the process in running
_check_process( ) {

  _get_process_pid

  [[ -n "${AZKABAN_PROCESS_PID}" ]] && kill -0 "${AZKABAN_PROCESS_PID}" &>/dev/null || return 1
}


##
# Start the process
_do_start_server( ) {

  CLASSPATH=""

  for file in ${AZKABAN_HOME}/{lib,extlib,plugins}/*.jar; do
    CLASSPATH=${CLASSPATH}:${file}
  done 2>/dev/null

  # Hadoop support
  [[ -n "${HADOOP_HOME}" ]] && {

    _console "Using Hadoop from: ${HADOOP_HOME}"
    CLASSPATH=${CLASSPATH}:${HADOOP_HOME}/conf:${HADOOP_HOME}/*
    JAVA_LIB_PATH="-Djava.library.path=${HADOOP_HOME}/lib/native/Linux-amd64-64"
  } || {

    _console "Error: HADOOP_HOME is not set. Hadoop job types will not run properly."
  }

  [[ -n "${HIVE_HOME}" ]] && {

    _console "Using Hive from: ${HIVE_HOME}"
    CLASSPATH=${CLASSPATH}:${HIVE_HOME}/conf:${HIVE_HOME}/lib/*
  }

  AZKABAN_OPTS="${AZKABAN_OPTS} -D__AZKABAN_SOLO__ -Dlog4j.configuration=file:/etc/azkaban-solo/log4j.properties -server -Dcom.sun.management.jmxremote -Djava.io.tmpdir=${AZKABAN_TMP} -Dexecutorport=${AZKABAN_EXECUTOR_PORT} -Dserverpath=${AZKABAN_HOME}"

  ${JAVA_HOME}/bin/java ${AZKABAN_OPTS} -classpath ${CLASSPATH} azkaban.webapp.AzkabanSingleServer -conf /etc/azkaban-solo ${@}
}


##
# Stop the process
_do_stop_server( ) {

  _get_process_pid

  [[ -n "${AZKABAN_PROCESS_PID}" ]] || _die "I can't find the process" 1

  _check_process
  
  [[ ${?} -eq 0 ]] && kill -TERM "${AZKABAN_PROCESS_PID}" || _die "I can't found any process with PID: ${AZKABAN_PROCESS_PID}" 2
}


##
# Minimal requirements
[[ -n "${AZKABAN_HOME}" ]] || _die "AZKABAN_HOME evironment variable is not set" 1
[[ -n "${JAVA_HOME}"    ]] || _die "JAVA_HOME evironment variable is not set" 1


##
# ::main::
case ${1} in
  start|stop) 
    _do_${1}_server
    ;;

  restart) 
    _do_stop_server &&
    _do_start_server
    ;;

  *) 
    _die "WTF! I don't know what hell is '${1}'" 1
    ;;
esac

