#--------------------------------------------------------------------
# Copyright 2020. Bioinformatic and Genomics Lab.
# Hanyang University, Seoul, Korea
# Coded by Jang-il Sohn (sohnjangil@gmail.com)
#--------------------------------------------------------------------  

#############################
#
# Help message
#

function USAGE {
    echo -e "$VERSION"
    echo -e "Usage: etching [options]"
    echo -e 
    echo -e "Example)"
    #echo -e "If you want to run ETCHING for panel data (-T P), panel_1.fq and panel_2.fq,"
    #echo -e "of 150bp insert-size (-L 150) and 0.5 tumor purity (-P 0.5) with 30 thread (-t 30)"
    #echo -e "using Random Forest scorer (-R) on working directory workdir (-w workdir)"
    #echo -e "with mathed normal samples, normal_1.fq and normal_2.fq,"
    #echo -e "run following command"
    echo -e "\$ etching -1 panel_1.fq -2 panel_2.fq -1c normal_1.fq -2c normal_2.fq -p test_out -t 30 -w workdir -T P -L 150 -P 0.5"
    echo -e 
    echo -e "[[Required]]"
    echo -e "[Sample (tumor in somatic call)]"
    echo -e "-1  (string)\tFirst fastq file of paired-end"
    echo -e "-2  (string)\tSecond fastq file of paired-end"
    echo -e "           \t-1 and -2 must be used together."
    echo -e "-b  (string)\tAligned bam file of paired-end"
    echo -e "           \tDo not use -b along with -1 or -2."
    echo -e
    echo -e "[Reference genome]"
    echo -e "-g  (string)\tBWA indexed reference genome."
    echo -e
    echo -e
    echo -e "[[Options]]"
    echo -e "-p  (string)\tPrefix of output [etching]"
    echo -e "-t  (int)   \tNumber of threads [8]"
    echo -e "-l  (int)   \tk-mer size (<=32) [31]"
    echo -e "            \tPlease check k-mer size before using -f option."
    echo -e "            \tOur default k-mer size of PGK is 31."
    echo -e "-w  (string)\tWorking directory [./working]"
    echo -e "-a  (string)\tAnnotation file in gtf [null]"
    echo -e "            \tUse this option, if you want to predict fusion-gene in a genome level."
    echo -e
    echo -e "[Sample options]"
    echo -e "-T  (string)\tW for WGS, P for Panel [W]"
    echo -e "-P  (double)\tTumor purity in somatic call (0-1) [0.75]"
    echo -e "            \tNote: Set 1 for germline call."
    echo -e "-K  (int)   \tK-mer frequency cut-off for removing sequencing errors from"
    echo -e "            \tsample sequencing reads [automatic]"
    #echo -e "            \tThough ETCHING can calculate optimal cut-off automatically,"
    echo -e "            \tif you want to specify it, we recommand 3-7 for WGS data, and"
    echo -e "            \t5-10 for targeted panel sequencing data."
    echo -e "            \tThe lesser, the more sensitive, and the more, the more specific."
    echo -e "-M  (int)   \tExclude the k-mers counted more than this [10000]."
    echo -e "-I  (int)   \tInsert-size [500]"
    echo -e "-L  (int)   \tRead-length [automatic]"
    echo -e "-O  (string)\tRead-orientation FR or RF. [FR]"
    echo -e "-D  (int)   \tSequencing depth [automatic]"
    echo -e "            \tIn case of WGS, sequencing depth is calculated automatically using k-mer histogram."
    echo -e "            \tNote: In case of panel, sequencing data have ~500X or more depth. However, we set"
    echo -e "            \tdefault to 50 for panel, because it works well"
    echo -e
    echo -e "[Control options]"
    echo -e "Control sample (matched normal in somatic call)"
    echo -e "-1c (string)\tFirst fastq file of paried-end [null]"
    echo -e "-2c (string)\tSecond fastq file of paried-end [null]"
    echo -e "            \t-1c and -2c must be used together."
    echo -e "-bc (string)\tAligned bam file of paried-end [null]"
    echo -e 
    echo -e "[K-mer database]"
    echo -e "-f  (string)\tPrefix of KMC3 k-mer database [null]"
    echo -e "            \tIf you have /path/to/PGK.kmc_pre and /path/to/PGK.kmc_suf,"
    echo -e "            \tyou can use \"-f /path/to/PGK\""
    echo -e 
    echo -e "[Initial SV call]"
    echo -e "-A          \tUse all split-reads [Null]"
    echo -e "            \tThis option increases recall. However,"
    echo -e "            \tlots of folse-positives also can be generated."
    echo -e 
    echo -e "[FP SV removing]"
    echo -e "-R          \tRandom Forest in scoring [default]"
    echo -e "-X          \tXGBoost in scoring"
    echo -e "-C  (double)\tCut-off of false SVs [0.4]"
    echo -e "-m  (string)\tPath to ETCHING machine learning model [\$ETCHING_ML_PATH]"
    echo -e 
    echo -e "[About ETCHING]"
    echo -e "-h          \tPrint this message"
    echo -e "-v          \tPrint version"
    echo -e 
    echo -e 
    echo -e "[[Contact]]"
    echo -e "Please report bugs to"
    echo -e "\tJang-il Sohn (sohnjangil@gmail.com)"
    echo -e "\tJin-Wu Nam (jwnam@hanyang.ac.kr)"
    echo -e
}

#####################################

if [ $# -lt 1 ]
then
    USAGE
    exit -1
fi

FIRST=
SECOND=
BAM=
GENOME=

PREFIX=etching
THREADS=8
KL=31
WORKDIR=working

ANNOTATION=

DATATYPE=W
PURITY=0.75
KMERCUTOFF=
MAXK=10000
INSERTSIZE=500
READLENGTH=
ORIENT=FR

FIRST_CONT=
SECOND_CONT=
BAM_CONT=
FILTER=

ALLSPLIT=
DEPTH=

ALGOR=
ALGOR_R=0
ALGOR_X=0
CUTOFF=0.4

while [ "$1" != "" ]; do
    case $1 in
        -1 | --first )  shift
            FIRST=$1
            ;;
        -2 | --second )  shift
            SECOND=$1
            ;;
        -b | --bam )  shift
            BAM=$1
            ;;
        -g | --genome )  shift
            GENOME=$1
            ;;


        -p | --prefix )  shift
            PREFIX=$1
            ;;
        -t | --threads ) shift
	    THREADS=$1
            ;;
        -l | --k-mer-size ) shift
	    KL=$1
            ;;
        -w | --work_dir ) shift
	    WORKDIR=$1
            ;;


        -a | --annotation ) shift
	    ANNOTATION=$1
            ;;


        -T | --data_type ) shift
	    DATATYPE=$1
            ;;
        -P | --purity ) shift
	    PURITY=$1
            ;;
        -K | --kmer_cutoff ) shift
	    KMERCUTOFF=$1
            ;;
        -M | --max-k-mer-freq ) shift
	    MAXK=$1
            ;;
        -I | --insert ) shift
	    INSERTSIZE=$1
            ;;
        -L | --read_length ) shift
	    READLENGTH=$1
            ;;
        -O | --orientation ) shift
	    ORIENT=$1
            ;;
        -D | --sequencing_depth ) shift
	    DEPTH="-D "$1
            ;;


        -1c | --first )  shift
            FIRST_CONT=$1
            ;;
        -2c | --second )  shift
            SECOND_CONT=$1
            ;;
        -bc | --bam )  shift
            BAM_CONT=$1
            ;;
	-f | --k-mer-database ) shift
	    FILTER=$1
	    ;;


        -A | --all_split )
	    ALLSPLIT="-A"
            ;;


        -R | --random_forest )
	    ALGOR_R=1
            ;;
        -X | --xgboost )
	    ALGOR_X=1
            ;;
        -C | --cutoff ) shift
	    CUTOFF=$1
            ;;
        -m | --path_to_machine_learning_model ) shift
	    ML_PATH=$1
            ;;


        -h | --help ) USAGE
            exit
            ;;


        -v | --help ) echo -e $VERSION
            exit
            ;;

	* ) 
	    echo "ERROR!!! Unavailable option: $1"
	    echo "-------------------------------"
	    USAGE
	    exit -1
	    ;;
    esac
    shift
done


#############################
#
# ETCHING starts here
#

echo "[ETCHING START]"
DATE="[$(date)]"
echo ${DATE}

#############################
#
# Checking required options
#

if [ ${#FIRST} != 0 ] && [ ${#SECOND} != 0 ]
then
    if [ ! -f ${FIRST} ]
    then
	echo "ERROR!!! Ther is no ${FIRST}".
	exit -1
    fi

    if [ ! -f ${SECOND} ]
    then
        echo "ERROR!!! Ther is no ${SECOND}".
	exit -1
    fi
else
    if [ ${#BAM} != 0 ]
    then
	if [ ! -f ${BAM} ]
	then
            echo "ERROR!!! Ther is no ${BAM}".
	    exit -1
	fi
    else
        echo "ERROR!!! Please check required option"
        echo "-------------------------------------"
        USAGE
        exit -1
    fi
fi


#############################
#
# CHECKING REFERENCE GENOME
#
if [ ${#GENOME} == 0 ]
then
    echo "ERROR!!! -g (reference_genome) is required"
    echo "------------------------------------------"
    USAGE
    exit -1
fi

if [ ! -f ${GENOME} ]
then
    echo "ERROR!!! There is no reference genome: $GENOME"
    echo "----------------------------------------------"
    USAGE
    exit -1
fi



#############################
#
# CHECKING ANNOTATION
#

if [ ${#ANNOTATION} != 0 ]
then
    if [ ! -f ${ANNOTATION} ]
    then
	echo "ERROR!!!"
	echo "There is no annotation file: ${ANNOTATION}"
	exit -1
    fi
fi



#############################
#
# Setting sequencing data type
#
if [ ! ${DATATYPE} == "W" ] && [ ! ${DATATYPE} == "P" ]
then
    echo "ERROR!!! -T must be used with W or P."
    echo "---------------------------"
    USAGE
    exit -1
fi


#############################
#
# CHECK ORIENTATION
#
if [ "$ORIENT" != "FR" ] && [ "$ORIENT" != "RF" ]
then
    echo "ERROR!!!"
    echo "-O must be FR or RF"
    exit -1
fi 



#############################
#
# Checking control sample options
#

if [ ${#FIRST_CONT} != 0 ]
then
    if [ ! -f ${FIRST_CONT} ]
    then
	echo "ERROR!!! Ther is no ${FIRST_CONT}".
	exit -1
    fi
fi

if [ ${#SECOND_CONT} != 0 ]
then
    if [ ! -f ${SECOND_CONT} ]
    then
	echo "ERROR!!! Ther is no ${SECOND_CONT}".
	exit -1
    fi
fi


if [ ${#BAM_CONT} != 0 ]
then
    if [ ! -f ${BAM_CONT} ]
    then
        echo "ERROR!!! Ther is no ${BAM_CONT}".
	exit -1
    fi
fi

FILTER_PRE=${FILTER}.kmc_pre
FILTER_SUF=${FILTER}.kmc_suf

if [ ${#FILTER} != 0 ]
then
    if [ ! -f ${FILTER_PRE} ] || [ ! -f ${FILTER_SUF} ]
    then
        echo "ERROR!!! Ther is no ${FILTER}".
	exit -1
    fi
fi



#############################
# 
# Setting algorithm parameter
#
if [ ${ALGOR_R} == 1 ] && [ ${ALGOR_X} == 1 ]
then
    echo "ERROR!!! -R and -X can not used together."
    echo "-----------------------------------------"
    USAGE
    exit -1
fi

# Setting default algorithm
if [ ${ALGOR_R} == 0 ] && [ ${ALGOR_X} == 0 ]
then
    ALGOR_R=1
 fi

if [ ${ALGOR_R} == 1 ]
then 
    ALGOR="-R"
fi

if [ ${ALGOR_X} == 1 ]
then 
    ALGOR="-X"
fi


#############################
# 
# Check machine learning paths and files
#
if [ ${#ETCHING_ML_PATH} == 0 ] && [ ${#ML_PATH} == 0 ]
then
    echo "ERROR!!!"
    echo "You need to set"
    echo " export ETCHING_ML_PATH=/path/to/etching/ML_model"
    echo "or run with the option"
    echo " -m /path/to/etching/ML_model"
    exit -1
fi

if [ ${#ML_PATH} != 0 ]
then
    PRESENT_PATH=$PWD
    cd ${ML_PATH}
    ML_PATH=$PWD
    cd $PRESENT_PATH
fi


CHECK_PATH=$ETCHING_ML_PATH
if [ ${#ML_PATH} != 0 ]
then
    CHECK_PATH=$ML_PATH
fi

TMP="rf"
if [ $ALGOR == "-X" ]
then
    TMP="xgb"
fi

for i in {1..10}
do
    if [ ! -f ${CHECK_PATH}/etching_${TMP}_${i}.sav ]
    then
	echo "ERROR!!!"
	echo "No model files in ${CHECK_PATH}"
	echo "-------------------------------"
	exit -1
    fi
done


#############################
#
# CHECKING REQUIRED PROGRAMS
#
DIR=$(echo $0 | sed 's/etching//g')
echo $DIR
for i in etching_filter estimate_coverage etching_caller etching_sorter etching_fg_identifier kmer_filter read_collector read_length_calc fastq_check
do
    CHECK=$(which ${DIR}${i})
    
    if [ ${#CHECK} == 0 ]
    then
	echo "ERROR!!! We cannot find ${i}. Please check PATH."
	echo "."
	exit -1
    fi

done



for i in etching_caller etching_sorter etching_fg_identifier read_collector read_length_calc fastq_check
do
    CHECK=$(${DIR}${i} 2> library_check.txt)
    CHECK=$(cat library_check.txt)
    if [ ${#CHECK} != 0 ]
    then
	cat library_check.txt
	echo "Please check LD_LIBRARY_PATH"
	exit -1
    fi
done


for i in kmc kmc_tools kmc_dump
do
    CHECK=$(which ${i})
    
    if [ ${#CHECK} == 0 ]
    then
	echo "ERROR!!!"
	echo "KMC3 was not install properly."
	exit -1
    fi
done


if [ ${#MAPPER} == 0 ]
then
    MAPPER="bwa"
    CHECK=$(which $MAPPER)
    
    if [ ${#CHECK} == 0 ]
    then
	echo "ERROR!!!"
	echo "bwa was not found"
	exit -1
    fi
    MAPPER="bwa mem"
fi




if [ ${#SAMTOOLS} == 0 ]
then
    SAMTOOLS=samtools
fi

CHECK=$(which $SAMTOOLS)

if [ ${#CHECK} == 0 ]
then
    echo "ERROR!!!"
    echo "samtools was not installed"
    exit -1
fi


#######################################################################################
#
# check working directory
#
if [ ! -d $WORKDIR ]
then
    echo "mkdir $WORKDIR"
    mkdir $WORKDIR
#else
    #echo "WARNING!!! There is working directory: $WORKDIR"
fi

cmd="cd $WORKDIR"
echo $cmd
eval $cmd


if [ ${#FIRST} != 0 ] 
then
    FC=$(echo $FIRST | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $FIRST
    else
	ln -s ../$FIRST
    fi
    FIRST=$(echo $FIRST | awk -F "/" '{print $NF}')
fi

if [ ${#FIRST_CONT} != 0 ] 
then
    FC=$(echo $FIRST_CONT | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $FIRST_CONT
    else
	ln -s ../$FIRST_CONT
    fi
    FIRST_CONT=$(echo $FIRST_CONT | awk -F "/" '{print $NF}')
fi


if [ ${#SECOND} != 0 ] 
then
    FC=$(echo $SECOND | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $SECOND
    else
	ln -s ../$SECOND
    fi
    SECOND=$(echo $SECOND | awk -F "/" '{print $NF}')
fi


if [ ${#SECOND_CONT} != 0 ] 
then
    FC=$(echo $SECOND_CONT | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $SECOND_CONT
    else
	ln -s ../$SECOND_CONT
    fi
    SECOND_CONT=$(echo $SECOND_CONT | awk -F "/" '{print $NF}')
fi


if [ ${#BAM} != 0 ] 
then
    FC=$(echo $BAM | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $BAM
    else
	ln -s ../$BAM
    fi
    BAM=$(echo $BAM | awk -F "/" '{print $NF}')
fi


if [ ${#BAM_CONT} != 0 ] 
then
    FC=$(echo $BAM_CONT | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $BAM_CONT
    else
	ln -s ../$BAM_CONT
    fi
    BAM_CONT=$(echo $BAM_CONT | awk -F "/" '{print $NF}')
fi
    
if [ ${#FILTER_PRE} != 0 ] 
then
    FC=$(echo $FILTER_PRE | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $FILTER_PRE
    else
	ln -s ../$FILTER_PRE
    fi
fi


if [ ${#FILTER_SUF} != 0 ] 
then
    FC=$(echo $FILTER_SUF | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $FILTER_SUF
    else
	ln -s ../$FILTER_SUF
    fi
fi
FILTER=$(echo $FILTER | awk -F "/" '{print $NF}')


if [ ${#ANNOTATION} != 0 ] 
then
    FC=$(echo $ANNOTATION | head -c 1 )
    if [ $FC == "/" ]
    then
	ln -s $ANNOTATION
    else
	ln -s ../$ANNOTATION
    fi
    ANNOTATION=$(echo $ANNOTATION | awk -F "/" '{print $NF}')
fi


if [ ${GENOME} != 0 ]
then
    FC=$(echo $GENOME | head -c 1 )
    if [ $FC != "/" ]
    then
	GENOME="../${GENOME}"
    fi
fi

#######################################################################################


#############################
#
# ETCHING FILTER
#

echo 
echo "[FILTER]"
DATE="[$(date)]";echo ${DATE}

mkdir logs

REQUIRED=
echo $FIRST
echo $SECOND

if [ ${#FIRST} != 0 ] && [ ${#SECOND} != 0 ]
then
    REQUIRED="-1 $FIRST -2 $SECOND -g ${GENOME}"
    echo $REQUIRED
else
    REQUIRED="-b $BAM -g ${GENOME}"
fi

OPTIONS=

if [ ${PREFIX} != 8 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -p $PREFIX"
    else
	OPTIONS="-p $PREFIX"
    fi
fi

if [ ${THREADS} != 8 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -t $THREADS"
    else
	OPTIONS="-t $THREADS"
    fi
fi

if [ ${KL} != 31 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -l $KL"
    else
	OPTIONS="-l $KL"
    fi
fi

if [ ${DATATYPE} != "W" ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -T ${DATATYPE}"
    else
	OPTIONS="-T $DATATYPE"
    fi
fi

if [ ${#KMERCUTOFF} != 0 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -K $KMERCUTOFF"
    else
	OPTIONS="-K $KMERCUTOFF"
    fi
fi

if [ ${#MAXK} != 10000 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -M $MAXK"
    else
	OPTIONS="-M $MAXK"
    fi
fi


if [ ${#FIRST_CONT} != 0 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -1c ${FIRST_CONT}"
    else
	OPTIONS="-1c ${FIRST_CONT}"
    fi
fi

if [ ${#SECOND_CONT} != 0 ]
    then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -2c ${SECOND_CONT}"
    else
	OPTIONS="-2c ${SECOND_CONT}"
    fi
fi

if [ ${#BAM_CONT} != 0 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -bc ${BAM_CONT}"
    else
	OPTIONS="-bc ${BAM_CONT}"
    fi
fi

if [ ${#FILTER} != 0 ]
then
    if [ ${#OPTIONS} != 0 ]
    then
	OPTIONS="${OPTIONS} -f ${FILTER}"
    else
	OPTIONS="-f ${FILTER}"
    fi
fi

cmd="${DIR}etching_filter ${REQUIRED} ${OPTIONS} > logs/ETCHING_FILTER.log"
echo $cmd
eval $cmd

#######################################################################################################################

#############################
#
# CALLER
#

echo
echo "[CALLER]"
DATE="[$(date)]";echo ${DATE}


if [ ${#READLENGTH} == 0 ]
then
    if [ ${#FIRST} != 0 ]
    then
	INPUT=$FIRST
    else 
	if [ ${#BAM} != 0 ]
	then
	    INPUT=$BAM
	fi
    fi
    cmd="${DIR}read_length_calc $INPUT 100000"
    echo $cmd
    READLENGTH=$(eval $cmd)
    echo "Read length: $READLENGTH"
fi


if [ ${#DEPTH} == 0 ]
then
    if [ $DATATYPE == "W" ]
    then 
	cmd="${DIR}estimate_coverage sample $READLENGTH $KL"
	echo $cmd
	DEPTH=$(eval $cmd)
	
	DEPTH="-D $DEPTH"
    fi
fi

cmd="${DIR}etching_caller -b ${PREFIX}.sort.bam -g $GENOME -o $PREFIX $DEPTH -P $PURITY -O $ORIENT $ALLSPLIT > logs/ETCHING_CALLER.log "
echo $cmd
eval $cmd

#######################################################################################################################
#############################
#
# SORTER
#
echo
echo "[SORTER]"
DATE="[$(date)]";echo ${DATE}

cmd="${DIR}etching_sorter -i ${PREFIX}.BND.vcf -o ${PREFIX}.BND -c $CUTOFF $ALGOR"
if [ ${#ML_PATH} != 0 ]
then
    cmd="${cmd} -m ${ML_PATH}"
fi
cmd="$cmd > logs/ETCHING_SORTER.BND.log "
echo $cmd
eval $cmd

cmd="${DIR}etching_sorter -i ${PREFIX}.SV.vcf -o ${PREFIX}.SV -c $CUTOFF $ALGOR"
if [ ${#ML_PATH} != 0 ]
then
    cmd="${cmd} -m ${ML_PATH}"
fi
cmd="$cmd > logs/ETCHING_SORTER.SV.log "
echo $cmd
eval $cmd

#######################################################################################################################
#############################
#
# FG_IDENTIFIER
#

if [ ${#ANNOTATION} != 0 ]
then
    echo
    echo "[FG_IDENTIFIER]"
    DATE="[$(date)]";echo ${DATE}
    
    cmd="${DIR}etching_fg_identifier ${PREFIX}.BND.etching_sorter.vcf $ANNOTATION > ${PREFIX}.BND.fusion_gene.txt"
    echo $cmd
    eval $cmd

    cmd="${DIR}etching_fg_identifier ${PREFIX}.SV.etching_sorter.vcf $ANNOTATION > ${PREFIX}.SV.fusion_gene.txt"
    echo $cmd
    eval $cmd
fi

cmd="cd -"
echo $cmd
eval $cmd

#######################################################################################################################
#############################
#
# COPY RESULTS
#

echo
echo "[RESULTS]"
#ln -s  ${WORKDIR}/${PREFIX}.BND.etching_sorter.vcf ${WORKDIR}/${PREFIX}.SV.etching_sorter.vcf ./
#cp  ${WORKDIR}/${PREFIX}.BND.etching_sorter.vcf ${WORKDIR}/${PREFIX}.SV.etching_sorter.vcf ./
#echo ${PREFIX}.BND.etching_sorter.vcf
#echo ${PREFIX}.SV.etching_sorter.vcf
cp ${WORKDIR}/${PREFIX}*etching_sorter.vcf ./
ls -1 ${PREFIX}*etching_sorter.vcf

if [ -f ${WORKDIR}/${PREFIX}.BND.fusion_gene.txt ]
then
    #ln -s ${WORKDIR}/${PREFIX}.BND.fusion_gene.txt 
    cp ${WORKDIR}/${PREFIX}.BND.fusion_gene.txt ./
    ls ${PREFIX}.BND.fusion_gene.txt
fi

if [ -f ${WORKDIR}/${PREFIX}.SV.fusion_gene.txt ]
then
    #ln -s ${WORKDIR}/${PREFIX}.SV.fusion_gene.txt 
    cp ${WORKDIR}/${PREFIX}.SV.fusion_gene.txt ./
    ls ${PREFIX}.SV.fusion_gene.txt
fi
echo
echo "[Finished]"
DATE="[$(date)]";echo ${DATE}
