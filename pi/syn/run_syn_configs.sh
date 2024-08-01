
for PIPESTAGES in 1 2 3 4
do 
    export M=1
    export N=1
    export K=32
    export CLKPRD=10000
    export CLKSPD=100
    export PIPESTAGES=$PIPESTAGES
    export P=8
    export TREE=1
    echo "RUN CONFIG: K=$K M=$M N=$N CLKPRD=$CLKPRD CLKSPD=$CLKSPD PIPESTAGES=$PIPESTAGES P=$P TREE=$TREE"
    ./run.sh
    
done