echo "FASTA File Statistics:"
echo "----------------------"

    number_of_seq=$(grep '>' $1 | wc -l)
echo "Number of sequences:" $number_of_seq
        
    total_length=$(awk '!/>/ {printf $0}' $1 | wc -c)
echo "Total length of sequences:" $total_length

    longest_seq=$(awk '!/>/{print}' $1 | sort -n | head -n 1| wc -c)
echo "Length of the longest sequence:" $longest_seq

    shortest_seq=$(awk '!/>/{print}' $1 | sort | tail -n 1 | wc -c)
echo "Length of the shortest sequence:" $shortest_seq

    average_seq=$(($total_length / $number_of_seq)) 
echo "Average sequence length:" $average_seq

    amount_GC=$(awk ' !/>/ {gc_count += gsub(/[GgCc]/, "", $1)} END {print gc_count}' $1)
    percentage_GC=$(echo "scale=2; $amount_GC / $total_length *100" |bc)
echo "GC Content (%):" $percentage_GC