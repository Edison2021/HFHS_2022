# $1  is sorted bam 

java -Xmx8g -jar picard.jar CollectRnaSeqMetrics STRAND_SPECIFICITY=NONE VALIDATION_STRINGENCY=SILENT REF_FLAT=/home/bwu3/src/human_ribosomal/GRCh38.ref_flat.txt RIBOSOMAL_INTERVALS=/home/bwu3/src/human_ribosomal/GRCh38.interval_list.txt CHART_OUTPUT=/home/bwu3/ribsome_RNA/$1.coverage.pdf INPUT=/mnt/BigData1/Susie/PlatesRNA.HISAT2.RF/bam1_4/$1 OUTPUT=/home/bwu3/ribsome_RNA/$1.rnaseqmetrics.dat 

head -n 8 /home/bwu3/ribsome_RNA/$1.rnaseqmetrics.dat |tail -n +2| awk '{print $16}' >/home/bwu3/ribsome_RNA/$1.ribo.txt