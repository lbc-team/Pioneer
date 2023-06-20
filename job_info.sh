#!/bin/sh
# 用法: ./job_info.sh fileName

# lines=$(($(cat $1 | grep -v ^$ | wc -l)))
lines=$(python validLine.py $1)
reviews=$((lines/4))

echo "- Markdown文件： [$1](https://github.com/lbc-team/Pioneer/blob/master/$1)"
echo "- 预计翻译时间： 5 天"
echo "- 预计校对时间： 3 天"
echo "- 翻译奖励学分： $lines 分"
echo "- 校对奖励学分： $reviews 分"
echo "\n"
echo "---"
echo "> 回复”认领翻译“ 即可认领翻译任务。"
echo "> 翻译及校对学分按行数统计，参考[规则](https://github.com/lbc-team/Pioneer/wiki/%E5%8F%82%E4%B8%8E%E7%99%BB%E9%93%BE%E7%BF%BB%E8%AF%91%E8%AE%A1%E5%88%92%EF%BC%8C%E5%81%9A-web3-%E4%B8%AD%E6%96%87%E5%86%85%E5%AE%B9%E7%9A%84%E6%8B%93%E8%8D%92%E8%80%85)"
