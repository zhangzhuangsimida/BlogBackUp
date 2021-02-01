#!/usr/bin/env sh
# echo "start debug"
# hexo cl
# hexo g
# hexo s
# echo "finish debug"


if [ "$1"x = "build"x ]; then
  buildFun
elif [ "$1"x = "server"x ]; then
  buildFun
  hexo s
elif [ "$1"x = "publish"x ]; then
  buildFun
  hexo d
else
  echo "请输入正确的参数 （build,debug,deploy) $1"
fi
# echo "start debug"
# hexo s
# echo "finish debug"

buildFun() {
  hexo cl
  hexo g
}
