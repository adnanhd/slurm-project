#!/usr/bin/make

batch_file=.batch.lock
proc_file=.proc.lock
slurm=train debug prepare 
SLURM_PREFIX=./slurm
out_files=$(wildcard ${SLURM_PREFIX}/*.out)
err_files=$(wildcard ${SLURM_PREFIX}/*.err)

ifndef JOB_ID
	JOB_ID=$(shell tail -1 ${proc_file})
endif

all: show list

echo:
	@echo ${JOB_ID}

list:
	squeue -u ${USER}

show:
	@cat ${proc_file}

${slurm}: %: %.slurm
	@sbatch $< | tee -a ${batch_file}
	@tail -1 ${batch_file} | awk '{ print $$4 }' >> ${proc_file}

cancel kill: #${proc_file}
	scancel ${JOB_ID}
	@sed -i '/${JOB_ID}/d' ${proc_file}

drop:
	@sed -i '/${JOB_ID}/d' ${proc_file}

empty:
	@rm ${proc_file}

less more head tail vim cat: #${proc_file}
	$@ ${SLURM_PREFIX}/${JOB_ID}.out 
	$@ ${SLURM_PREFIX}/${JOB_ID}.err

clean:
	rm $(out_files) $(err_files)
.PHONY: list kill stop cancel ${slurm} less more head tail clean

