# Running the local CME flow analysis

This directory contains a small, reproducible example for running the ALICE
O2Physics task `o2-analysis-cf-flow-pid-cme`.

The aim of this document is to explain the workflow from the beginning. It is
written for someone who is comfortable using a terminal, but who is new to
Linux shell scripts, ROOT files, and O2Physics.

## 1. What is being analysed?

The **Chiral Magnetic Effect (CME)** is a possible charge separation effect
in heavy-ion collisions. The task used here studies flow and particle
identification observables that can be used in CME analyses.

The analysis does not read ordinary text files. It reads an ALICE **AO2D**
file. An AO2D file is a ROOT file containing tables of reconstructed
collisions, tracks, detector information, and analysis-specific columns.
The task applies selections and calculates observables, then writes the
results to another ROOT file.

The important pieces are:

| Item | Meaning |
| --- | --- |
| `AO2D_flowinput.root` | AO2D input used by the local run |
| `configuration_local.json` | Analysis settings for a completely local run |
| `run_local.sh` | The short command that starts the analysis task |
| `O2Physicsrun.sh` | Convenience wrapper that loads the O2Physics environment |
| `configuration.json` | Configuration intended for the normal, non-local workflow |
| `run.sh` | Longer preprocessing workflow that creates a flow-input AO2D |
| `make_small_aod.py` | Optional utility for making a small test AO2D |
| `ccdb-local/` | Local CCDB files used by `configuration_local.json` |
| `AnalysisResults.root` | ROOT output produced by a previous analysis run |

Files ending in `.root` can be large and are ignored by Git in this
directory. Do not replace a large input file until you are sure that you have
another copy.

## 2. A few concepts before starting

### The terminal

Commands below are typed into a shell. A command usually has this form:

```text
program option value
```

For example, `pwd` prints the current directory and `ls` lists its contents.
The command `cd DIRECTORY` changes the current directory.

### A shell script

A file ending in `.sh` is a list of shell commands. `bash run_local.sh`
executes such a file using Bash. The command `source FILE` loads environment
variables and functions into the current shell; this is necessary before
O2Physics programs can be found.

### ROOT and AO2D

ROOT is the data-analysis framework used by CERN experiments. A ROOT file
usually has the extension `.root`. It is not a plain text file, so opening it
with a text editor will not show useful data.

### O2Physics and workflows

O2Physics provides analysis executables. Here,
`o2-analysis-cf-flow-pid-cme` is the executable. The `-b` option runs without
interactive graphics. `--configuration` supplies JSON settings, and
`--aod-file` supplies the AO2D input.

## 3. Prerequisites

You need:

1. Access to the ALICE analysis cluster or another machine with a compatible
   O2Physics installation.
2. The O2Physics environment used by this directory.
3. The input file `AO2D_flowinput.root`.
4. The local CCDB directory `ccdb-local/`.

This checkout currently expects the environment at:

```text
/data/alice/aenderic/o2physics_env.sh
```

That path is specific to the current installation. If the directory is moved
or copied to another account, edit the paths in `O2Physicsrun.sh` and
`configuration_local.json`, or use the manual setup below.

Do not add grid certificates, private keys, or other credentials to this
directory. They are not needed for the local workflow.

## 4. First run: the local analysis

Open a terminal and run:

```bash
cd /data/alice/aenderic/CME_verify_results
bash O2Physicsrun.sh
```

The wrapper performs three things:

1. Sets the ALICE software work directory.
2. Loads `/data/alice/aenderic/o2physics_env.sh`.
3. Changes to this directory and starts `run_local.sh`.

The same run can be started manually:

```bash
cd /data/alice/aenderic/CME_verify_results
source /data/alice/aenderic/o2physics_env.sh
command -v o2-analysis-cf-flow-pid-cme
bash run_local.sh
```

The `command -v` line should print the location of the executable. If it
prints nothing, the O2Physics environment was not loaded correctly.

The final command in `run_local.sh` is:

```bash
o2-analysis-cf-flow-pid-cme -b \
  --configuration json://configuration_local.json \
  --aod-file AO2D_flowinput.root \
  --shm-segment-size 4000000000 \
  --aod-memory-rate-limit 200000000
```

Here:

- `json://configuration_local.json` tells O2Physics to read the local JSON
  configuration.
- `AO2D_flowinput.root` is the input file. Because it has no directory
  component, the command must be run from `CME_verify_results/`.
- `--shm-segment-size` reserves shared memory for the workflow.
- `--aod-memory-rate-limit` limits the rate at which AO2 reads input data.

The memory values are in bytes. If the job is killed because the machine has
less available memory, reduce them only after checking the cluster's memory
limit and discussing the change with the person supervising the analysis.

## 5. Checking that the run worked

The program prints progress and errors in the terminal. A successful run
should finish without an error or segmentation fault and should update or
create ROOT output in this directory.

Useful checks are:

```bash
ls -lh *.root
ls -lh AnalysisResults.root
```

To inspect a ROOT file interactively, start ROOT after loading the environment:

```bash
source /data/alice/aenderic/o2physics_env.sh
root AnalysisResults.root
```

Inside ROOT, commands such as `.ls` list objects in the file and `.q` exits.
The exact object names depend on the task and configuration.

Keep a record of the input filename, configuration file, software version,
date, and any changed cuts whenever you produce physics results. A result
without this information is difficult to reproduce.

## 6. Making a small test input

The full AO2D can be too large for a first test. The utility
`make_small_aod.py` copies a selected number of data frames:

```bash
cd /data/alice/aenderic/CME_verify_results
source /data/alice/aenderic/o2physics_env.sh
python3 make_small_aod.py AO2D_flowinput.root AO2D_small.root -n 3
```

The option `-n 3` copies three data frames. To skip the first five frames and
copy the next two:

```bash
python3 make_small_aod.py AO2D_flowinput.root AO2D_small.root -n 2 --skip 5
```

This script needs PyROOT, which is provided by the O2Physics environment.
Creating a small file does not automatically make `run_local.sh` use it.
For a test, either temporarily change the `--aod-file` value in the script or
make a backup of the script before editing it.

## 7. How the input AO2D can be produced

`run.sh` contains a longer O2Physics pipeline. It chains several analysis
tasks with the pipe character (`|`), so the output of one task becomes the
input of the next task. At the end, the pipeline writes an AO2D called
`AO2D_flowinput.root`.

This is separate from the short local run:

- Use `run.sh` when you need to build or rebuild the flow-input AO2D from
  another input listed in `input_data.txt`.
- Use `run_local.sh` when `AO2D_flowinput.root` already exists and you only
  want to run `o2-analysis-cf-flow-pid-cme` locally.

Do not run the long pipeline merely to repeat the local analysis; it can use
substantially more CPU, memory, and disk space.

## 8. Understanding the configuration

`configuration_local.json` is JSON: a text format consisting of named keys
and values. The keys are passed to the O2Physics task. For example, the
`flow-pid-cme` section contains event, track, centrality, and histogram
settings.

The local configuration points to:

```text
file:///data/alice/aenderic/CME_verify_results/ccdb-local
```

This means that the run reads calibration and condition data from the local
`ccdb-local/` directory instead of contacting the remote ALICE CCDB service.
`configuration.json` instead uses the remote CCDB URL and is therefore not
the default for an offline/local run.

When changing a setting:

1. Make one small change at a time.
2. Keep a copy of the original configuration.
3. Run on `AO2D_small.root` first when possible.
4. Record the changed key and its old and new values.
5. Confirm that the output and event counts still make sense.

## 9. Common problems

### `o2-analysis-cf-flow-pid-cme: command not found`

The environment is not loaded, or the installed O2Physics version does not
contain the task. Run:

```bash
source /data/alice/aenderic/o2physics_env.sh
command -v o2-analysis-cf-flow-pid-cme
```

### `cannot open AO2D_flowinput.root`

Check that the file exists and that you are in the correct directory:

```bash
pwd
ls -lh AO2D_flowinput.root
```

### A local CCDB file cannot be found

Check that `ccdb-local/` exists and that the `ccdbUrl` in
`configuration_local.json` still points to its absolute path.

### The job runs out of memory or is killed

The workflow uses shared memory and reads a large ROOT file. Try the small
AO2D first. If the full job still exceeds the machine's limit, ask the
administrator or supervisor which memory settings are appropriate before
changing `--shm-segment-size` or `--aod-memory-rate-limit`.

### The shell script says `Permission denied`

Run it explicitly with Bash:

```bash
bash run_local.sh
```

Making a script executable is also possible:

```bash
chmod u+x run_local.sh
./run_local.sh
```

## 10. Suggested learning path

1. Learn `pwd`, `ls`, `cd`, `source`, and `bash`.
2. Run the executable check with `command -v`.
3. Run the local analysis on the provided input.
4. Make and inspect `AO2D_small.root`.
5. Change one configuration value and compare the output.
6. Read the O2Physics task documentation and the source code before making
   physics conclusions.

This README describes how to run the workflow; it does not establish the
physics validity of a result. Selection choices, detector corrections,
systematic uncertainties, and validation plots must be reviewed with the
analysis group.
