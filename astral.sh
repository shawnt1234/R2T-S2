#PBS -S /bin/bash
#PBS -N j_ASTRAL
#PBS -q batch
#PBS -l nodes=1:ppn=1
#PBS -l walltime=20:00:00
#PBS -l mem=30gb

#PBS -M shawnt@uga.edu 
#PBS -m ae

cd $PBS_O_WORKDIR

ml ASTRAL/5.6.1-Java-1.8.0_144

time java -jar $EBROOTASTRAL/astral.5.6.1.jar -i 47concat.tre -q mainast.tre -t 8 -o 47_3qscore.tre