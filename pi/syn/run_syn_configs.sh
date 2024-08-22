for i in 2
do 
    export M=1
    export N=1
    export K=32
    export CLKSPD=300
    export CLKPRD=3333
    export PIPESTAGES=2
    export P=8
    export TREE=1
    export CONFIGURABLE=0
    echo "RUN CONFIG: K=$K M=$M N=$N CLKPRD=$CLKPRD CLKSPD=$CLKSPD PIPESTAGES=$PIPESTAGES P=$P TREE=$TREE CONFIGURABLE=$CONFIGURABLE"
    ./run.sh
    
done