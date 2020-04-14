import gzip
import sys
import re

file_name = sys.argv[1]
out_file_name = sys.argv[2]

pat = re.compile(r"DP=(\d+)")
list_depth = []

with gzip.open(file_name, "rt") as fi:
    for line in fi:
        if not line.startswith("chr"):
            continue
        cols = line.strip("\n").split("\t")
        info_values = cols[7]
        m = pat.search(info_values)
        if m:
            depth = int(m.group(1))
            list_depth.append(depth)
ave_depth = sum(list_depth) / len(list_depth)

with open(out_file_name, "w") as f:
    f.write(f"ave_depth_of_homo_snp\t{ave_depth:.1f}\n")

