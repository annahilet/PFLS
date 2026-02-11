#!/bin/bash

# --------------------------
# Settings
# --------------------------
RAW_DIR="RAW-DATA"
TRANSLATION_FILE="$RAW_DIR/sample-translation.txt"
COMBINED_DIR="$(pwd)/COMBINED-DATA"

# Create combined directory
mkdir -p "$COMBINED_DIR"

# --------------------------
# Loop over each library
# --------------------------
for dir in "$RAW_DIR"/*/; do
    library_name=$(basename "$dir")

    # Get culture name
    culture_name=$(awk -v lib="$library_name" '$1 == lib {print $2}' "$TRANSLATION_FILE")
    if [[ -z "$culture_name" ]]; then
        echo "Warning: No culture found for $library_name"
        continue
    fi

    # --------------------------
    # Copy metadata
    # --------------------------
    cp "${dir}/checkm.txt" "$COMBINED_DIR/${culture_name}-CHECKM.txt"
    cp "${dir}/gtdb.gtdbtk.tax" "$COMBINED_DIR/${culture_name}-GTDB-TAX.txt"

    # --------------------------
    # Initialize counters
    # --------------------------
    MAG_counter=1
    BIN_counter=1

    # --------------------------
    # Process fasta files
    # --------------------------
    for fasta in "$dir"/bins/*.fasta; do
        file_base=$(basename "$fasta")

        # ----------------------------------
        # Handle UNBINNED
        # ----------------------------------
        if [[ "$file_base" == "bin-unbinned.fasta" ]]; then
            new_name="${culture_name}_UNBINNED.fa"
            seq_counter=1

            awk -v prefix="${culture_name}-UNBINNED" '
            BEGIN {OFS=""}
            /^>/ {
                printf(">%s-%03d\n", prefix, seq_counter)
                seq_counter++
                next
            }
            { print }
            ' "$fasta" > "$COMBINED_DIR/$new_name"

    
            continue
        fi

        # ----------------------------------
        # Handle normal bins (MAG or BIN)
        # ----------------------------------
        bin_name=$(basename "$fasta" .fasta)
        bin_number=$(echo "$bin_name" | grep -o '[0-9]\+')

        read completion contamination < <(
            awk -v num="$bin_number" '$1 ~ num {print $13, $14}' "$dir/checkm.txt"
        )

        if [[ -z "$completion" || -z "$contamination" ]]; then
            echo "Warning: Missing stats for $fasta"
            continue
        fi

        if awk "BEGIN {exit !($completion >= 50 && $contamination <= 5)}"; then
    type="MAG"
    number=$(printf "%03d" $MAG_counter)
    ((MAG_counter++))
else
    type="BIN"
    number=$(printf "%03d" $BIN_counter)
    ((BIN_counter++))
fi

new_name="${culture_name}_${type}_${number}.fa"

seq_counter=1
awk -v prefix="${culture_name}-${type}-${number}" '
BEGIN {OFS=""}
/^>/ {
    printf(">%s-%03d\n", prefix, seq_counter)
    seq_counter++
    next
}
{ print }
' "$fasta" > "$COMBINED_DIR/$new_name"


    done

done
