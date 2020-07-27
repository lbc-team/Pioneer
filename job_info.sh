#!/bin/sh
# 用法: ./job_info.sh fileName

lines=$(($(cat $1 | grep -v ^$ | wc -l)))
reviews=$((lines/4))

echo "- Markdown文件： [$1](https://github.com/lbc-team/Pioneer/blob/master/layer2/Ethereum-Smart-Contracts-in-L2-Optimistic-Rollup.md)"
echo "- 预计翻译时间： 5 天"
echo "- 预计校对时间： 3 天"
echo "- 翻译奖励学分： $lines 分"
echo "- 校对奖励学分： $reviews 分"
echo "\n"
echo "---"
echo "> 回复”认领翻译“ 即可认领翻译任务。"
echo "> 翻译及校对学分按行数统计，参考[规则](https://learnblockchain.cn/article/796)"