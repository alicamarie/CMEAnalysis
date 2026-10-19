#!/usr/bin/env python3
"""Make a small AO2D by copying the first N data frames.

Usage: python3 make_small_aod.py AO2D.root small_AO2D.root -n 3
Run it inside the O2Physics environment (needs PyROOT).
"""
import argparse
import ROOT

ROOT.gROOT.SetBatch(True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("-n", "--ndf", type=int, default=3, help="number of DFs to copy")
    ap.add_argument("--skip", type=int, default=0, help="skip the first SKIP DFs")
    args = ap.parse_args()

    fin = ROOT.TFile.Open(args.input)
    if not fin or fin.IsZombie():
        raise SystemExit(f"cannot open {args.input}")

    names = list(dict.fromkeys(k.GetName() for k in fin.GetListOfKeys()))
    df_names = [n for n in names if n.startswith("DF_")]
    other = [n for n in names if not n.startswith("DF_")]
    print(f"{len(df_names)} data frames in input")

    selected = df_names[args.skip:args.skip + args.ndf]
    if not selected:
        raise SystemExit("no data frames selected")

    fout = ROOT.TFile.Open(args.output, "RECREATE")
    fout.SetCompressionSettings(fin.GetCompressionSettings())

    # top-level objects (e.g. metaData)
    for n in other:
        obj = fin.Get(n)
        if obj:
            fout.cd()
            fout.WriteObject(obj, n)

    for name in selected:
        din = fin.Get(name)
        dout = fout.mkdir(name)
        for tname in dict.fromkeys(k.GetName() for k in din.GetListOfKeys()):
            obj = din.Get(tname)
            dout.cd()
            if obj.InheritsFrom("TTree"):
                new = obj.CloneTree(-1, "fast")
                new.Write()
            else:
                dout.WriteObject(obj, tname)
        print(f"copied {name}")

    fout.Close()
    fin.Close()
    print(f"written {args.output}")


if __name__ == "__main__":
    main()