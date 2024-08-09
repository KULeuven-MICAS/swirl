for i in 1 3 4
do 
    export M=1
    export N=1
    export K=32
    export CLKSPD=300
    export CLKPRD=3333
    export PIPESTAGES=$i
    export P=8
    export TREE=1
    echo "RUN CONFIG: K=$K M=$M N=$N CLKPRD=$CLKPRD CLKSPD=$CLKSPD PIPESTAGES=$PIPESTAGES P=$P TREE=$TREE"
    ./run.sh
    
done