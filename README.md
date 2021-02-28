# snippy-pan
Provides a pan-genome variant matrix from snippy-core full genome alignments. It will output a tsv table of all sites that have at least one 'N' regardless of if there is a SNP at that site or not. Such a matrix is useful to look for deletions relative to a reference or the discovery of SNP sites that are in the accessory genome that therefore would not feature in any snippy-core outfiles.


### get the code
    $ git clone https://github.com/abuultjens/snippy-pan.git

### run the script 
    $ snippy-pan.sh [snippy-core.full.clean.aln] [fofn.txt] [OUTFILE]
    
##### arguments: 
``snippy.full.clean.aln`` snippy whole genome multi fasta alignment with sequence blocks consiting of only: A, G, C, T and N. This can be done with snippy-clean_full_aln (https://github.com/tseemann/snippy)  
``fofn.txt`` single column text file with ordered list of isolate names
``OUTFILE`` name of outfile (will be tab seperated)

# Outfile
The header line will have all isolates in the same order as the fofn.txt file. The first column is an index with the position of the variant in the snippy-core full genome alignment. Numbers larger than the reference chromosome will occur when the ref contains plasmids. 

# Example

### run snippy
    $ snippy --outdir isolate_1 --ref ref.gbk --R1 isolate_1_R1.fq.gz --R2 isolate_1_R2.fq.gz  
    $ snippy --outdir isolate_2 --ref ref.gbk --R1 isolate_2_R1.fq.gz --R2 isolate_2_R2.fq.gz  
    $ snippy --outdir isolate_3 --ref ref.gbk --R1 isolate_3_R1.fq.gz --R2 isolate_3_R2.fq.gz
    
### run snippy-core
    $ snippy-core --prefix test --ref ref.gbk isolate_1 isolate_2 isolate_3  
    
### run snippy-clean_full_aln
    $ snippy-clean_full_aln test.full.aln > test.full.clean.aln  
    
### run snippy-pan.sh
    $ snippy-pan.sh test.full.clean.aln fofn.txt test.full.clean.pan.tab  
    
    
