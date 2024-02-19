from pathlib import Path
import yaml
    

def main():
    chapterdir = Path('./myChapters/')
    chapters = [str(x) for x in chapterdir.glob("*.md")]
    with open("_quarto.yml", 'r+') as f:
        current = yaml.safe_load(f)
        current['book']['chapters'] = ['index.qmd'] + sorted(chapters, key=lambda x: (len(x), x))
        f.seek(0)
        yaml.dump(current, f)

if __name__ == "__main__":
    main()
