set xlabel 'Size'
set ylabel 'Time (usec)'

set term png
set output './out/analysis.png'

plot '/tmp/.cuda_tmp_analyse.csv' using 1:2 with linespoints lt rgb "red" title 'PLAIN', \
     '/tmp/.cuda_tmp_analyse.csv' using 1:3 with linespoints lt rgb "orange" title 'OPENCV', \
     '/tmp/.cuda_tmp_analyse.csv' using 1:4 with linespoints lt rgb "green" title 'CUDA'
