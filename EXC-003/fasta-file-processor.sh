for fasta in *.fa  
do 
    number_of_sequences=$(grep '>' $fasta | wc -l)
    echo "The total number of sequences": $number_of_sequences
done 