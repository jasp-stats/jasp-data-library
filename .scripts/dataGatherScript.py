from pathlib import Path
from zipfile import ZipFile
import argparse
from shutil import copy, move



def gather_datasets(path_str, out_path):
    path = Path(path_str)
    datasets_path = path / 'Resources' / 'Data Sets' / 'Data Library'
    out_path = Path(out_path)

    if(not datasets_path.exists()):
        print('dataset path not found')
        return

    #gather all data files paths that have name.csv AND name.jasp
    jaspFiles = set(datasets_path.glob("**/*.jasp"))
    csvFiles = [x.with_suffix('.csv') for x in jaspFiles if x.with_suffix('.csv').exists()]
    jaspFiles = [x.with_suffix('.jasp') for x in csvFiles]

    #copy & extract the relevant parts of the jasp files 
    for file in jaspFiles:
        extract_target_path = out_path / file.stem
        extract_target_path.mkdir(parents=True, exist_ok=True)
        copy(file.absolute(), extract_target_path.absolute())
        with ZipFile(file.absolute(), 'r') as zip:
            members = ['index.html'] + [i for i in zip.namelist() if i.startswith('resources') and i.find('state') == -1] 
            zip.extractall(path=extract_target_path.absolute(), members=members)

    #add the csvs
    for file in csvFiles:
        target_path = out_path / file.stem
        target_path.mkdir(parents=True, exist_ok=True)
        copy(file.absolute(), target_path.absolute())

    #rename all index.html to parent folder
    indexFiles = set(out_path.glob("*/index.html"))
    for file in indexFiles:
        move(file.absolute(), file.with_stem(file.parts[-2].replace(' ', '_')))




    

def main():
    parser = argparse.ArgumentParser(
                    prog='python3 pkglist',
                    description='Takes a directory containing jasp and creates a folder containing relevant elements for each dat set in the output dir',
                    epilog='example: python3 dataGatherScript.py ~/jasp-desktop/ ~output/')
    parser.add_argument('jasp_dir')
    parser.add_argument('output_dir')
    args = parser.parse_args()
    gather_datasets(args.jasp_dir, args.output_dir)

if __name__ == "__main__":
    main()