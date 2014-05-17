for v in `ls | grep roll`
do
  convert $v -negate $v
done
