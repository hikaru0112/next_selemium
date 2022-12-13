#!/usr/bin/env bash
set -e
ARCH=`uname -m`
echo $ARCHs
if [ -z "$(docker container ls -q -f name='next-app')" ]; then
    echo "container build"
    
    case $ARCH in
        "x86_64" )
            nohup docker compose -f docker-compose.yml up next-app selenium-hub selenium-node  &>/dev/null &
        ;;
        "arm64" )
            nohup docker compose -f docker-compose.yml -f docker-compose-arm.yml up next-app selenium-hub selenium-node  &>/dev/null &
        ;;
    esac
    while :; do
        #nextが起動するまで待機する
        if [ "$(curl -fs localhost:8080 | grep '<html>')" ] &&
        [ "$(curl -fs http://localhost:4444/ui | grep '<!doctype html>')"  ]; then
            echo "next-app container build complete."
            break # 起動したら抜ける
        fi
        sleep 1
    done
fi

echo "start selenium test."
if [ ! -e ./selenium_log ]; then
    # 存在しない場合
    mkdir ./selenium_log
fi

#いい感じにlogファイルに保存させる
case $ARCH in
    "x86_64" )
        docker compose -f docker-compose.yml up selenium-test-runner | (
            v=$(cat)
            printf "$v"
            echo "$v" | grep --line-buffered 'selenium-test-runner' |
            awk '/> test/,/exited with code/' |
            cut -f 2 -d "|" |
        sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" > ./selenium_log/node-$(date +%Y%m%d%H%M).log)
        
    ;;
    "arm64" )
        docker compose -f docker-compose.yml -f docker-compose-arm.yml up selenium-test-runner | (
            v=$(cat)
            printf "$v"
            echo "$v" | grep --line-buffered 'selenium-test-runner' |
            awk '/> test/,/exited with code/' |
            cut -f 2 -d "|" |
        sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" > ./selenium_log/node-$(date +%Y%m%d%H%M).log)
    ;;
esac

