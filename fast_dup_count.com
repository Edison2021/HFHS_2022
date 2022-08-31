#### for RNAseq; remove duplication is not ideal given they are usualaly high duplicaiton rate in nature######
# install picard
# $1 is sorted bam
samtools view -H $1 | grep '^@RG'

# add RG group; SO will resorted the bam file 
java -jar picard.jar AddOrReplaceReadGroups I=$1 O=$1\_added_sorted.bam SO=coordinate RGID=WK RGLB=WK RGPL=illumina RGPU=illumina RGSM=WK

# detect dup; READ_NAME_REGEX=null will ignore optical duplcation; Invoking the TAGGING_POLICY option, you can instruct the program to mark duplicate type; all the duplicates (All), only the optical duplicates (OpticalOnly), or no duplicates (DontTag); REMOVE_DUPLICATES=TURE will delete all duplcates!!!

java -Xmx4g -jar picard.jar MarkDuplicates I=$1\_added_sorted.bam O=$1\_dedupped.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT M=$1.dupmetrics.dat 


# save the disk and in most time you will need it
rm $1\_dedupped.bam
rm $1\_added_sorted.bam

head -8 $1.dupmetrics.dat | tail -1 | cut -f9 >dup.txt
