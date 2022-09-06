#!/bin/bash

# This is an How to do Reproducible Research sessions into The Rockfish cluster.

# NOTE:
#      1. singularity containers cannot run from a scratch folder
#      2. Volume path (singularity BIND) must be absolute

salloc -J interact -N 1-1 -n 4 --time=1:00:00 -p defq srun --pty bash

pip3 install git+https://github.com/ricardojacomini/rf.git --upgrade --user --force
pip3 install graphviz --user

curl -s https://raw.githubusercontent.com/ricardojacomini/rf/master/scripts/install_tree_non_root.sh | bash

cat > ~/.local/bin/rc << EOF
#!/bin/bash
if [ ! \$# -eq 0  ]; then
    echo "\$1" | tr "[ATGCatgc]" "[TACGtacg]" | rev
else
    echo ""
    echo "usage: rc DNASEQUENCE"
    echo ""
fi
EOF

chmod +x ~/.local/bin/rc

mkdir $HOME/snakemake_rf_training/; cd $HOME/snakemake_rf_training/

git init
git remote add -f origin https://github.com/ricardojacomini/arch-tutorial.git

# sparse checkouts
git config --global core.sparsecheckout true

echo "tutorial/*" >> .git/info/sparse-checkout

# fetch the files from the remote Git repository
git pull origin main

# How to do Reproducible Research,
# see more details used in this tutorial in:

# http://marcc.rtfd.io

# https://snakemake.readthedocs.io/en/v3.10.1/getting_started/examples.html
# https://snakemake.readthedocs.io/en/stable/tutorial/basics.html