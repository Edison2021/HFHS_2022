#### for ribosome.interval_list.txt#######
# you may downlaode the files directly
# Create a .dict file for our reference 
# $1 is ref $2 is gtf
# install PICARD gff2bed gtfToGenePred (see https://rnabio.org/module-00-setup/0000/10/01/Installation/)

java -Xmx8g -jar picard.jar CreateSequenceDictionary R=$1 O=$1.dict

# Create a bed file of the location of ribosomal sequences in our reference (first extract from the gtf then convert to bed)

grep --color=none -i rrna $2 > ref_ribosome.gtf
gff2bed < ref_ribosome.gtf > ref_ribosome.bed

# Create interval list file for the location of ribosomal sequences in our reference

java  -Xmx8g -jar picard.jar BedToIntervalList I=ref_ribosome.bed O=$1.interval_list.txt SD=$1.dict

#### for flat txt##########
# Create a genePred file for our reference transcriptome

gtfToGenePred -genePredExt $2 $1.ref_flat.txt

# reformat this genePred file

cat $1.ref_flat.txt | awk '{print $12"\t"$0}' | cut -d$'\t' -f1-11 > tmp.txt

mv tmp.txt $1.ref_flat.txt
