import os
import subprocess

ROOT = os.path.dirname(os.path.abspath(__file__))

langs = [
    "C#", "C++", "Clojure", "CoffeeScript", "CommonLisp",
    "Crystal", "D", "Dart", "Elixir", "Elm",
    "EmacsLisp", "Erlang", "F#", "Go", "Groovy",
    "Hack", "Haskell", "Haxe", "Java", "JavaScript", 
    "Julia", "Kotlin", "Lua", "Nim", "Objective-C",
    "OCaml", "Perl", "PHP", "PureScript", "Python",
    "Racket", "Raku", "ReasonML", "ReScript", "Ruby",
    "Rust", "Scala", "Scheme", "StandardML", "Swift",
    "TypeScript", "VisualBasic"
]

with open("expected.out", "r") as f:
    gold_answer = f.read()


for lang in langs:
    work_dir = os.path.join(ROOT, lang)
    out_path = os.path.join(work_dir, "stringify.out")
    if os.path.exists(out_path):
        os.remove(out_path)
    subprocess.run(["bash execute.sh"], shell=True, stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL, cwd=work_dir)
    # should have created the file
    if not os.path.exists(out_path):
        print(f"{lang}: Failed to create output file.")
        continue
    with open(out_path, "r") as f:
        answer = f.read()
    if answer != gold_answer:
        print(f"{lang}: Output mismatch")
    else:
        print(f"{lang}: OK")
    


