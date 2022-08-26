# minimap2 only accept one input each time, you may condider pbmm2 for mutiple inputs together 
# http://www.htslib.org/doc/samtools-view.html
# https://wikis.utexas.edu/display/CoreNGSTools/Filtering+with+SAMTools
# install minimap2 samtools bedtools seqtk PRINCESS

echo "mapping your read now"
minimap2 -ax map-hifi -t 8 ref.fa pacbio-ccs.fq.gz | samtools sort -@ 4 -m 4G > sorted.alignment.bam 
samtools index sorted.alignment.bam

echo "extracting mapped seq based on your bed file"
#bed.list has a format like chr1 1 256
# -b can have mutiple inputs
# -f how much coverage in a 
samtools view -b -F 4 in.bam > in.1.bam
bedtools bamtobed -i in.1.bam | awk '{print $1 "\t" $2 "\t" $3}'>reads.bed
bedtools intersect -a reads.bed -b target.bed.list -wa >reads.1.bed
awk '{print $1}' reads.1.bed > reads.name
seqtk  subseq pacbio-ccs.fq.gz reads.name >pacbio-ccs.fq.1.gz

echo "generating phased SNPs"
samtools faidx genome.fa 
princess all  -d analysis -r ccs -f genome.fa  -s HiFi.fastq.gz 


