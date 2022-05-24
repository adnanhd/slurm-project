#!/usr/bin/make

batch_file=.batch.lock
proc_file=.proc.lock
slurm_prefix=/home/aharun/.slurm

slurm_ids=$(shell cat ${batch_file} | awk '{ print $$4 }')
out_files=$(patsubst %, ${slurm_prefix}/%.out, ${slurm_ids})
err_files=$(patsubst %, ${slurm_prefix}/%.err, ${slurm_ids})
slurm_files=$(patsubst %.slurm, %, $(wildcard *.slurm))


all: list

list:
	squeue -u ${USER}

${slurm_files}: %: %.slurm
	@sbatch $< | tee -a ${batch_file}

${proc_file}: ${batch_file}
	@tail -1 $^ | awk '{ print $$4 }' > $@

cancel kill stop: ${proc_file}
	scancel $(shell head -1 ${proc_file})
	@head -n -1 ${batch_file} > ${proc_file}
	@mv ${proc_file} ${batch_file}
	@tail -1 ${batch_file} | awk '{ print $$4 }' > ${proc_file}

less more head tail vim cat: ${proc_file}
	$@ ${slurm_prefix}/$(shell head -1 ${proc_file}).out
	$@ ${slurm_prefix}/$(shell head -1 ${proc_file}).err

clean:
	rm $(out_files) $(err_files)
.PHONY: all list ${slurm_files} kill stop cancel less more head tail clean
