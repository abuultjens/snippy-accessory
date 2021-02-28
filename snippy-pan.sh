#!/bin/bash

# read pos args
ALIGNMENT=${1}
FOFN=${2}
OUTFILE=${3}

# set n parallel processes
N_SPLIT=10

# index input mfa
samtools faidx ${ALIGNMENT}

# generate random prefix for all tmp files
RAND_1=`echo $((1 + RANDOM % 100))`
RAND_2=`echo $((100 + RANDOM % 200))`
RAND_3=`echo $((200 + RANDOM % 300))`
RAND=`echo "${RAND_1}${RAND_2}${RAND_3}"`

# get number of taxa in fofn
N_TAXA=`wc -l ${FOFN} | awk '{print $1}'`

# split fofn
split -d -l ${N_SPLIT} ${FOFN} FOFN_${RAND}_

# make group fofn
ls FOFN_${RAND}_* > ${RAND}_FOFN.txt

# loop through groups
for GROUP in $(cat ${RAND}_FOFN.txt); do

	FILE=`echo ${GROUP}`

	# loop through isolates in group
	for TAXA in $(cat ${FILE}); do
		## write single line seq to file
		samtools faidx ${ALIGNMENT} ${TAXA} | grep -v ">" | tr -d '\n' | tr '-' 'N' >> ${RAND}_${TAXA}.seq &
	done

	wait

	# add line endings
	for TAXA in $(cat ${FILE}); do
		echo '' >> ${RAND}_${TAXA}.seq
	done

	wait

	# insert tabs between all chr
	for TAXA in $(cat ${FILE}); do
		sed 's/./&,/g' < ${RAND}_${TAXA}.seq | sed 's/.$//' | tr ',' '\t' > ${RAND}_${TAXA}.tsv.seq &
	done

	wait

done

# cat all single line seq files
for TAXA in $(cat ${FOFN}); do
	cat ${RAND}_${TAXA}.tsv.seq >> ${RAND}.tsv.seq
done

# transpose
datamash transpose -H < ${RAND}.tsv.seq > ${RAND}.tsv.tr.tmp.seq

# make header
tr '\n' '\t' < ${FOFN} | sed s/\t$// > ${RAND}.tsv.tr.seq
echo '' >> ${RAND}.tsv.tr.seq

# add header
cat ${RAND}.tsv.tr.tmp.seq >> ${RAND}.tsv.tr.seq

# make index
LINES=`wc -l ${RAND}.tsv.tr.tmp.seq | awk '{print $1}'`
echo "INDEX" > seq_1-${LINES}_${RAND}.txt
seq 1 ${LINES} >> seq_1-${LINES}_${RAND}.txt

# add index
paste seq_1-${LINES}_${RAND}.txt ${RAND}.tsv.tr.seq > ${RAND}_ALL.tsv.tr.seq

# write header to outfile
head -1 ${RAND}_ALL.tsv.tr.seq > ${OUTFILE}

# write body to outfile
tail -n +2 ${RAND}_ALL.tsv.tr.seq | grep "N" >> ${OUTFILE}

# rm tmp files		
rm *${RAND}*
