#!/usr/bin/env sh
# echo "start debug"
# hexo cl
# hexo g
# hexo s
# echo "finish debug"


if [ "$1"x = "b"x ]; then
  hexo clean
  hexo g
elif [ "$1"x = "s"x ]; then
  hexo clean
  hexo g
  hexo s
elif [ "$1"x = "p"x ]; then
  hexo clean
  hexo g
  hexo d
else
  echo "请输入正确的参数 （build = b,server = s,publish = p) $1"
fi
# echo "start debug"
# hexo s
# echo "finish debug"
