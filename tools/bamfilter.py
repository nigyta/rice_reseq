import sys
import os.path
import pysam

help_msg = """
Usage:
    python bamfilter.py input.bam outprefix

Function:
1. Remove low MQ alignments (<10)
2. Remove alignments with both-ends clipped (len>5)
3. Separate properly-mapped and inproperly-mapped reads

outputs:
    outprefix.proper.bam
    outprefix.inproper.bam
"""

if len(sys.argv) != 3:
    print(help_msg)
    exit()

input_bam_file = sys.argv[1] 
outprefix = sys.argv[2]

output_bam_file_proper = outprefix + ".proper.bam"
output_bam_file_inproper = outprefix + ".inproper.bam"


def is_both_ends_clipped(read, threshold=5):
    first_cigar = read.cigartuples[0]
    last_cigar = read.cigartuples[-1]
    left_clipped = first_cigar[0] == 4 or first_cigar[0] == 5
    left_clipped_length = first_cigar[1] if left_clipped else 0
    right_clipped = last_cigar[0] == 4 or last_cigar[0] == 5
    right_clipped_length = last_cigar[1] if right_clipped else 0
    if left_clipped_length > threshold and right_clipped_length > threshold:
        return True
    else:
        return False


def is_low_mapq(read, threshold=10):
    return True if read.mapping_quality < threshold else False



input_bam = pysam.AlignmentFile(input_bam_file, "rb")
output_bam_proper = pysam.AlignmentFile(output_bam_file_proper, "wb", template=input_bam)
output_bam_inproper = pysam.AlignmentFile(output_bam_file_inproper, "wb", template=input_bam)

cnt_both_clipped, cnt_low_MQ, cnt_inproper, cnt_proper = 0, 0, 0, 0

for read in input_bam:
    if is_low_mapq(read):
        # print("removed by low-MQ")
        # print(read)
        cnt_low_MQ += 1
        continue
    if is_both_ends_clipped(read):
        # print("removed by both_ends_clipped", end="")
        # print(read.to_string())
        cnt_both_clipped += 1
        continue
    if read.is_proper_pair:
        output_bam_proper.write(read)
        cnt_proper += 1
    else:
        output_bam_inproper.write(read)
        cnt_inproper += 1

input_bam.close()
output_bam_proper.close()
output_bam_inproper.close()

print("cnt_both_clipped\tcnt_low_MQ\tcnt_inproper\tcnt_proper")
print(f"{cnt_both_clipped}\t{cnt_low_MQ}\t{cnt_inproper}\t{cnt_proper}")
