# Chiral Magnetic Effect with Particle Identification

This directory contains a small, reproducible example for running the ALICE
O2Physics task `o2-analysis-cf-flow-pid-cme` locally on the cluster, without
requiring Grid credentials or a remote AOD file.

The local run uses the AO2D file and CCDB snapshots bundled in this directory. No Grid certificate, Alien token, or network CCDB access is required.

## 1. Contents

The analysis reads an ALICE **AO2D** file. AO2D stands for Analysis Object
Data. An AO2D file is a ROOT file containing tables of reconstructed
collisions, tracks, detector information, and analysis-specific columns. The
task applies selections and calculates observables, then writes the results to
another ROOT file.

| Item | Meaning |
| --- | --- |
| `AO2D_small_LHC23zzh_with_input_local.root` | AO2D input used by the local run |
| `configuration_local.json` | Analysis settings for a completely local run |
| `run_local.sh` | Terminal script that loads O2Physics and starts the task |
| `ccdb-local/` | Local CCDB files used by the configuration |

The analysis output is created in this directory when the task produces it,
for example `AnalysisResults.root`. CCDB stands for Conditions and
Calibrations Database. The configuration uses the files in `ccdb-local/` for
the local inputs needed by this example.

## 2. Requirements

The included wrapper expects the O2Physics environment script at:

```text
/data/alice/aenderic/o2physics_env.sh
```

After loading the environment, this command should be available:

```text
o2-analysis-cf-flow-pid-cme
```

## 3. Run completely from a terminal

First, copy the **whole directory** to your work directory. Do not copy only
the script: the AO2D input file, configuration, and local CCDB files are all
required.

If the directory is copied to a different absolute path, update the
`file:///data/alice/aenderic/CME_verify_results/Input_for_Jae/ccdb-local`
entries in `configuration_local.json` so that they point to the copied
`ccdb-local/` directory. Leave the rest as it is.

Then change into the copied directory and start the wrapper:

```bash
chmod +x run_local.sh
./run_local.sh
```

The wrapper resolves its configuration and input paths relative to its own
location, so it can also be started using an absolute path:

```bash
/path/to/your/workdir/Input_for_Jae/run_local.sh
```

`run_local.sh` loads `/data/alice/aenderic/o2physics_env.sh` and starts the
task. If your O2Physics installation is in a different location, edit the
`source` line and the `ALIBUILD_WORK_DIR` value in `run_local.sh` before
running it.

The task is launched with:

```bash
o2-analysis-cf-flow-pid-cme -b \
  --configuration json://configuration_local.json \
  --aod-file AO2D_small_LHC23zzh_with_input_local.root \
  --shm-segment-size 4000000000 \
  --aod-memory-rate-limit 200000000
```

The `-b` option runs in batch mode. The shared-memory and AOD memory-rate
options match the tested local configuration. The command writes its output
in the current working directory.

## 4. O2Physics source code

The task implementation is available in the O2Physics repository:

- [flowPidCme.cxx on GitHub](https://github.com/AliceO2Group/O2Physics/blob/master/PWGCF/Flow/Tasks/flowPidCme.cxx)
- Local checkout: `/data/alice/aenderic/alice/O2Physics/PWGCF/Flow/Tasks/flowPidCme.cxx`

The executable `o2-analysis-cf-flow-pid-cme` is built from this task.

## 5. Troubleshooting

### Permission denied when starting the script

Make the wrapper executable once:

```bash
chmod +x run_local.sh
```

### O2Physics command not found

Check that the environment script exists and that it defines
`o2-analysis-cf-flow-pid-cme`:

```bash
test -f /data/alice/aenderic/o2physics_env.sh
source /data/alice/aenderic/o2physics_env.sh
command -v o2-analysis-cf-flow-pid-cme
```

### Missing input or configuration

Run the wrapper from this directory, or use its absolute path. Confirm that
the following paths exist:

```bash
test -f AO2D_small_LHC23zzh_with_input_local.root
test -f configuration_local.json
test -d ccdb-local
```

## 6. Notes

- Keep `configuration_local.json` and `ccdb-local/` together. The
  configuration points to the CCDB files bundled here.
- You can inspect the ROOT files using the VS Code ROOT extension.
