
#!/bin/bash

echo "Current working directory: $(pwd)"
echo "Input file check:"
ls -l input_data.txt || true
echo "Absolute input path:"
readlink -f input_data.txt || true

# o2-analysis-cf-flow-pid-cme -b --configuration json://configuration.json \
#   --dump-workflow --dump-workflow-file flow_only.json

KEEP="AOD/BC/1:O2bc_001,AOD/COLLISION/1:O2collision_001,AOD/TRACKEXTRA/2:O2trackextra_002,\
AOD/TRACK/0,AOD/TRACKDCA/0,AOD/TRACKSELECTION/0,AOD/TRACKSELEXTRA/0,\
AOD/EVSEL/0,AOD/TIMESTAMPS/0,AOD/CENTFT0C/0,\
AOD/FT0MULT/0,AOD/FV0MULT/0,AOD/FDDMULT/0,AOD/ZDCMULT/0,AOD/TPCMULT/0,AOD/PVMULT/0,AOD/TRKLTMULT/0,\
AOD/QVECTORDEVS/0,\
AOD/pidTPCFullPi/0,AOD/pidTPCFullKa/0,AOD/pidTPCFullPr/0,\
AOD/pidTOFFullPi/0,AOD/pidTOFFullKa/0,AOD/pidTOFFullPr/0"

o2-analysis-cf-flow-pid-cme -b --configuration json://configuration.json   --shm-segment-size 10000000000 | \
o2-analysis-trackselection -b --configuration json://configuration.json | \
o2-analysis-ft0-corrected-table -b --configuration json://configuration.json | \
o2-analysis-qvector-table -b --configuration json://configuration.json | \
o2-analysis-pid-tof-merge -b --configuration json://configuration.json | \
o2-analysis-pid-its -b --configuration json://configuration.json | \
o2-analysis-multcenttable -b --configuration json://configuration.json | \
o2-analysis-event-selection-service -b --configuration json://configuration.json | \
o2-analysis-propagationservice -b --configuration json://configuration.json | \
o2-analysis-pid-tpc-service -b --configuration json://configuration.json \
  --aod-file @input_data.txt \
  --shm-segment-size 10000000000 \
  --aod-memory-rate-limit 2000000000 \
  --aod-writer-resfile AO2D_flowinput \
  --aod-writer-keep "$KEEP"