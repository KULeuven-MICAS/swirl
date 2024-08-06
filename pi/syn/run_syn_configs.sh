for i in 200 250 300
do 
    export M=1
    export N=1
    export K=32
    export CLKSPD=$i
    export CLKPRD=(1000000/$CLKSPD)
    export PIPESTAGES=2
    export P=8
    export TREE=1
    echo "RUN CONFIG: K=$K M=$M N=$N CLKPRD=$CLKPRD CLKSPD=$CLKSPD PIPESTAGES=$PIPESTAGES P=$P TREE=$TREE"
    ./run.sh
    
done