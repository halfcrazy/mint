#!/usr/bin/env bash
#
#  Minio Cloud Storage, (C) 2017 Minio, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

cleanUp(){
    # remove binary 
    rm ./minio.test
}

build() {
    go get -u github.com/minio/minio-go
	go test -c api_functional_v4_test.go -o minio.test
}

run() {
    if [[ "$1" -eq "quick" ]]; then 
        chmod +x ./minio.test && ./minio.test -test.short -test.timeout 20m
    else
        chmod +x ./minio.test && ./minio.test -test.v -test.timeout 20m       
    fi
}

main() {
    logfile=$1
    errfile=$2
    run_mode=$3
    # Build test file binary
    build >>$logfile  2>&1 || { echo 'minio-go build failed' ; exit 1; }
  
    # run the tests
    rc=0

    run $run_mode 2>>$errfile 1>>$logfile && cleanUp || { echo 'minio-go run failed.'; rc=1; } 
    grep -e 'FAIL' $logfile >> $errfile
    return $rc
}

# invoke the script
main "$@"